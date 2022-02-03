part of mongo_dart;

class GridOut extends GridFSFile {
  GridOut(GridFS fs, [Map<String, dynamic>? data]) : super(fs, data);

  Future writeToFilename(String filename) => writeToFile(File(filename));

  Future writeToFile(File file) {
    var sink = file.openWrite(mode: FileMode.write);
    writeTo(sink).then((int length) {
      sink.close();
    });
    return sink.done;
  }

  Future<int> writeTo(IOSink out) {
    var length = 0;
    var completer = Completer<int>();
    void addToSink(Map<String, dynamic> chunk) {
      final data = chunk['data'] as BsonBinary;
      out.add(data.byteList);
      length += data.byteList.length;
    }

    fs.chunks
        .find(where.eq('files_id', id).sortBy('n'))
        .forEach(addToSink)
        .then((_) => completer.complete(length));
    return completer.future;
  }
}
