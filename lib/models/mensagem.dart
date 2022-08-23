class Mensagem {
  String idUsuario;
  String texto;
  String data;

  Mensagem({
    required this.idUsuario,
    required this.texto,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'idUsuario': idUsuario,
      'texto': texto,
      'data': data,
    };
  }
}
