import 'package:mongo_dart/mongo_dart.dart' show BsonBinary, MongoDartError;
import 'package:mongo_dart/src/database/message/mongo_modern_message.dart'
    show MongoModernMessage;
import 'payload.dart' show Payload, Payload0, Payload1;

abstract class Section {
  int payloadType;
  Payload payload;

  Section._(this.payloadType, this.payload);

  factory Section(int payloadType, Map<String, Object> data) {
    if (payloadType == MongoModernMessage.basePayloadType) {
      return SectionType0.fromDocument(payloadType, data);
    } else if (payloadType == MongoModernMessage.documentsPayloadType) {
      return SectionType1.fromDocument(payloadType, data);
    }
    throw MongoDartError('Unknown Payload Type "$payloadType"');
  }

  factory Section.fromBuffer(BsonBinary buffer) {
    var payloadType = buffer.readByte();
    if (payloadType == MongoModernMessage.basePayloadType) {
      return SectionType0(payloadType, Payload0.fromBuffer(buffer));
    } else if (payloadType == MongoModernMessage.documentsPayloadType) {
      return SectionType1(payloadType, Payload1.fromBuffer(buffer));
    }
    throw MongoDartError('Unknown Payload Type "$payloadType"');
  }

  int get byteLength => 1 /* payloadType */ + payload.byteLength;

  void packValue(BsonBinary buffer) {
    buffer.writeByte(payloadType);
    payload.packValue(buffer);
  }
}

class SectionType0 extends Section {
  SectionType0.fromDocument(int payloadType, Map<String, Object> document)
      : super._(payloadType, Payload0(document));

  SectionType0(int payloadType, Payload0 payload)
      : super._(payloadType, payload);
}

class SectionType1 extends Section {
  factory SectionType1.fromDocument(
      int payloadType, Map<String, Object> document) {
    if (document.length > 1) {
      throw MongoDartError('Expected only one element in the '
          'document while generating section 1');
    }
    if (document.values.first is! List) {
      throw MongoDartError(
          'The value of the document parameter must be a List of documents');
    }
    var identifier = document.keys.first;
    var documents = document.values.first as List<Map<String, Object?>>;
    //payload = Payload1(identifier, documents);
    return SectionType1(payloadType, Payload1(identifier, documents));
  }

  SectionType1(int payloadType, Payload1 payload)
      : super._(payloadType, payload);
}

/* void _arrangeBuffer(BsonBinary buffer) {
  if (buffer.byteList == null) {
    buffer.makeByteList();
  } else {
    buffer.makeHexString();
  }
} */
