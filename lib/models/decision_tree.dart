import 'dart:math';

class DecisionTreeNode {
  String? attribute;
  String? label;
  Map<String, DecisionTreeNode>? children;
  Map<String, double>? percentages;

  DecisionTreeNode(
      {this.attribute, this.label, this.children, this.percentages});
}

class C45DecisionTree {
  List<Map<String, String>> data;
  List<String> attributes;
  String targetAttribute;

  C45DecisionTree(this.data, this.attributes, this.targetAttribute);

  // Metode untuk menghitung entropi
  double _entropy(List<Map<String, String>> subset) {
    Map<String, int> labelCounts = {};
    for (var instance in subset) {
      String label = instance[targetAttribute] ?? 'null';
      if (!labelCounts.containsKey(label)) {
        labelCounts[label] = 0;
      }
      labelCounts[label] = labelCounts[label]! + 1;
    }

    double entropy = 0.0;
    int totalInstances = subset.length;
    labelCounts.forEach((label, count) {
      double proportion = count / totalInstances;
      entropy -= proportion * (proportion > 0 ? log(proportion) / ln2 : 0);
    });

    return entropy;
  }

  // Metode untuk menghitung gain
  double _gain(List<Map<String, String>> subset, String attribute) {
    double totalEntropy = _entropy(subset);
    Map<String, List<Map<String, String>>> subsets = {};

    for (var instance in subset) {
      String attributeValue = instance[attribute] ?? 'null';
      if (!subsets.containsKey(attributeValue)) {
        subsets[attributeValue] = [];
      }
      subsets[attributeValue]!.add(instance);
    }

    double subsetEntropy = 0.0;
    int totalInstances = subset.length;
    subsets.forEach((attributeValue, subset) {
      double proportion = subset.length / totalInstances;
      subsetEntropy += proportion * _entropy(subset);
    });

    return totalEntropy - subsetEntropy;
  }

  // Metode untuk memilih atribut terbaik
  String _bestAttribute(
      List<Map<String, String>> subset, List<String> attributes) {
    double bestGain = -1.0;
    String bestAttribute = attributes.first;

    for (var attribute in attributes) {
      double gain = _gain(subset, attribute);
      if (gain > bestGain) {
        bestGain = gain;
        bestAttribute = attribute;
      }
    }

    return bestAttribute;
  }

  // Metode untuk menghitung persentase label
  Map<String, double> _calculateLabelPercentages(
      List<Map<String, String>> subset) {
    Map<String, int> labelCounts = {};
    for (var instance in subset) {
      String label = instance[targetAttribute] ?? 'null';
      if (!labelCounts.containsKey(label)) {
        labelCounts[label] = 0;
      }
      labelCounts[label] = labelCounts[label]! + 1;
    }

    int totalInstances = subset.length;
    Map<String, double> labelPercentages = {};
    labelCounts.forEach((label, count) {
      labelPercentages[label] = (count / totalInstances) * 100;
    });

    return labelPercentages;
  }

  // Metode untuk membangun pohon keputusan
  DecisionTreeNode _buildTree(
      List<Map<String, String>> subset, List<String> attributes) {
    Set<String> labels =
        subset.map((instance) => instance[targetAttribute] ?? 'null').toSet();
    if (labels.length == 1) {
      return DecisionTreeNode(
          label: labels.first, percentages: _calculateLabelPercentages(subset));
    }

    if (attributes.isEmpty) {
      String majorityLabel = labels.reduce((a, b) => subset
                  .where((instance) => instance[targetAttribute] == a)
                  .length >
              subset.where((instance) => instance[targetAttribute] == b).length
          ? a
          : b);
      return DecisionTreeNode(
          label: majorityLabel,
          percentages: _calculateLabelPercentages(subset));
    }

    String bestAttr = _bestAttribute(subset, attributes);
    Map<String, List<Map<String, String>>> subsets = {};

    for (var instance in subset) {
      String attributeValue = instance[bestAttr] ?? 'null';
      if (!subsets.containsKey(attributeValue)) {
        subsets[attributeValue] = [];
      }
      subsets[attributeValue]!.add(instance);
    }

    Map<String, DecisionTreeNode> children = {};
    List<String> remainingAttributes =
        attributes.where((attr) => attr != bestAttr).toList();

    for (var attrValue in subsets.keys) {
      children[attrValue] =
          _buildTree(subsets[attrValue]!, remainingAttributes);
    }

    return DecisionTreeNode(
        attribute: bestAttr,
        children: children,
        percentages: _calculateLabelPercentages(subset));
  }

  // Metode untuk membangun pohon keputusan
  DecisionTreeNode build() {
    return _buildTree(data, attributes);
  }
}
