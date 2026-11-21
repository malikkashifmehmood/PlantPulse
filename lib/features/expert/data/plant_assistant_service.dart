import '../models/plant_assistant_message.dart';

class PlantAssistantService {
  String getReply(
    String question, {
    List<PlantAssistantMessage> conversation = const [],
  }) {
    final text = question.toLowerCase().trim();

    if (text.isEmpty) {
      return 'Please describe the problem you are noticing on your tomato plant.';
    }

    final contextText = _buildContext(text, conversation);

    if (RegExp(r'\b(hello|hi|hey|salam|assalam)\b').hasMatch(text)) {
      return 'Hello! I am the PlantPulse Plant Assistant. I can help with tomato leaf diseases, plant care, watering, and prevention. What is happening to your plant?';
    }

    if (_containsAny(text, ['thank', 'thanks', 'jazak'])) {
      return 'You are welcome! Keep monitoring your plant, and feel free to describe any new symptoms you notice.';
    }

    if (_containsAny(text, ['what can you do', 'help', 'who are you'])) {
      return 'I provide automated, general tomato plant-care guidance. You can ask about leaf spots, yellowing, wilting, pests, watering, or any of the ten disease categories supported by the PlantPulse model. I cannot replace a qualified agricultural expert.';
    }

    // Use the current message and relevant previous symptom description.
    if (_hasConcentricRings(contextText) &&
        _containsAny(contextText, [
          'older leaves',
          'lower leaves',
          'old leaves',
        ]) &&
        _containsAny(contextText, ['brown', 'dark'])) {
      return 'Small dark-brown spots with concentric rings that begin on older leaves are consistent with early blight. Target spot can produce similar ring-shaped lesions, so symptoms alone cannot confirm which disease is present. Check whether the spots have a yellow halo and whether similar lesions appear on stems or fruit. Remove severely affected leaves with clean tools, keep foliage dry, and improve airflow. A clear photo of both sides of an affected leaf would help with further assessment.';
    }

    if (_containsAny(contextText, ['early blight', 'early_blight'])) {
      return 'Early blight commonly causes brown, target-like spots with concentric rings, often on older leaves first. Remove badly affected leaves, avoid wetting foliage, improve airflow, and avoid working with plants while they are wet. Confirm the diagnosis before choosing a treatment because other leaf diseases can look similar.';
    }

    if (_containsAny(contextText, ['late blight', 'late_blight'])) {
      return 'Late blight can develop quickly in cool, humid conditions. Look for spreading, water-soaked or dark lesions; pale growth may appear on the underside of leaves in humid weather. Isolate affected plants where practical, avoid overhead watering, and seek prompt local agricultural advice if you suspect late blight.';
    }

    if (_containsAny(contextText, ['bacterial spot', 'bacterial_spot'])) {
      return 'Bacterial spot may cause small, dark, water-soaked lesions on leaves and sometimes raised spots on fruit. Avoid handling wet plants, reduce leaf wetness, remove severely affected plant material, and clean tools. Do not compost diseased material unless your local composting guidance confirms it is safe.';
    }

    if (_containsAny(contextText, ['leaf mold', 'leaf_mold'])) {
      return 'Tomato leaf mold is often associated with high humidity and poor airflow. Yellow patches may appear on the upper leaf surface, with olive or greyish growth underneath. Improve ventilation, space plants appropriately, and water near the soil rather than over the leaves.';
    }

    if (_containsAny(contextText, ['septoria', 'septoria_leaf_spot'])) {
      return 'Septoria leaf spot often produces many small, circular spots with pale or grey centres and darker edges, usually beginning on lower leaves. Remove affected leaves, keep foliage dry, improve airflow, and avoid moving contaminated plant debris around the garden.';
    }

    if (_containsAny(contextText, ['spider mite', 'spider_mites', 'mites'])) {
      return 'Spider mites are tiny pests that can cause fine pale stippling, yellowing, and sometimes delicate webbing under leaves. Inspect leaf undersides closely. Reduce dust and plant stress, and seek locally approved pest-management advice if the infestation is spreading.';
    }

    if (_containsAny(contextText, ['target spot', 'target_spot'])) {
      return 'Target spot can cause brown lesions with concentric rings and may resemble early blight. Check several leaves, including their undersides, and consider the pattern of spread. Keep foliage dry, improve airflow, and use a confirmed diagnosis before selecting a treatment.';
    }

    if (_containsAny(contextText, [
      'yellow leaf curl',
      'yellow_leaf_curl',
      'tylcv',
      'leaf curl virus',
    ])) {
      return 'Tomato yellow leaf curl virus can cause upward leaf curling, yellowing, smaller leaves, and stunted growth. Whiteflies can spread this virus. Inspect plants for whiteflies, remove severely affected plants according to local guidance, and use locally recommended measures to manage the insect vector.';
    }

    if (_containsAny(contextText, [
      'tomato mosaic',
      'tomato_mosaic',
      'mosaic virus',
    ])) {
      return 'Tomato mosaic virus may cause mottled light and dark green patterns, leaf distortion, and reduced growth. Avoid handling plants unnecessarily, clean tools and hands, and remove confirmed infected plants according to local guidance. There is no curative treatment for a virus-infected plant.';
    }

    if (_containsAny(contextText, ['healthy', 'healthy plant'])) {
      return 'A healthy tomato plant generally has firm stems, consistent green growth, and no spreading lesions or unusual distortion. Continue monitoring leaves, water consistently at soil level, provide suitable sunlight, and maintain airflow.';
    }

    if (_containsAny(contextText, [
      'water',
      'watering',
      'irrigation',
      'thirsty',
    ])) {
      return 'Water tomato plants deeply near the soil and let the soil condition guide the next watering. Avoid keeping the roots waterlogged and try to keep leaves dry. The amount and frequency depend on temperature, soil, container size, and plant growth.';
    }

    if (_containsAny(contextText, [
      'yellow leaves',
      'leaves yellow',
      'yellowing',
    ])) {
      return 'Yellow leaves can result from several causes, including watering problems, nutrient imbalance, pests, or disease. Are the older lower leaves yellow, or the newer upper leaves? Also check whether you see spots, curling, or insects underneath the leaves.';
    }

    if (_containsAny(contextText, [
      'fertilizer',
      'fertiliser',
      'nutrient',
      'feeding',
    ])) {
      return 'Tomatoes need balanced nutrition, but excess fertilizer can cause problems too. Follow the label of a fertilizer suitable for tomatoes and your growing conditions. If you describe the leaf symptoms and growing setup, I can help you think through possible nutrient issues.';
    }

    if (_containsAny(contextText, [
      'prevent',
      'prevention',
      'protect',
      'stop disease',
    ])) {
      return 'Useful prevention habits include spacing plants for airflow, watering at soil level, removing diseased leaves with clean tools, rotating tomato crops where possible, controlling weeds, and checking plants regularly. Avoid reusing contaminated plant debris.';
    }

    if (_containsAny(contextText, [
      'spots',
      'spot on',
      'brown leaves',
      'brown spots',
    ])) {
      return 'Leaf spots can have several causes, including early blight, Septoria, bacterial spot, and target spot. Please describe the spots: are they small or large, do they have rings, and are they mainly on older or newer leaves? A clear photo can help, but visual symptoms alone may not confirm the cause.';
    }

    if (_containsAny(contextText, ['wilting', 'wilt', 'drooping'])) {
      return 'Wilting may be caused by dry soil, waterlogged roots, heat stress, root damage, or disease. Check soil moisture first and inspect the stem and lower leaves. Is the plant recovering in the evening, or does it remain wilted overnight?';
    }

    return 'I am not confident enough to answer that accurately yet. Please tell me which plant part is affected, what the symptoms look like, and when they started. For serious or rapidly spreading problems, consult a local agricultural extension service or qualified plant-health expert.';
  }

  String _buildContext(
    String question,
    List<PlantAssistantMessage> conversation,
  ) {
    if (conversation.isEmpty) return question;

    // Find the latest assistant response.
    var assistantIndex = -1;

    for (var i = conversation.length - 1; i >= 0; i--) {
      if (!conversation[i].isUser) {
        assistantIndex = i;
        break;
      }
    }

    if (assistantIndex == -1) return question;

    final previousAssistantReply =
        conversation[assistantIndex].text.toLowerCase();

    // Only carry context forward when the assistant asked for clarification.
    final askedForDetails = _containsAny(previousAssistantReply, [
      'please describe',
      'describe the spots',
      'what symptoms',
      'which plant part',
      'are the older',
      'do they have',
      'when did they start',
      'check whether',
    ]);

    if (!askedForDetails) return question;

    // Find the user's message that preceded that clarification.
    for (var i = assistantIndex - 1; i >= 0; i--) {
      if (conversation[i].isUser) {
        return '${conversation[i].text.toLowerCase()} $question';
      }
    }

    return question;
  }

  bool _hasConcentricRings(String text) {
    return _containsAny(text, [
      'concentric rings',
      'concentric ring',
      'target-like rings',
      'rings',
    ]);
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any(text.contains);
  }
}
