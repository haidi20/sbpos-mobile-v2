import 'package:core/utils/helpers/api_exeption.dart';
import 'package:core/presentation/widgets/message_snackbar.dart';

mixin BaseErrorHelper {
  dynamic handleError(error) {
    if (error is BadRequestException) {
      var message = error.message;
      errorSnackBar(message.toString());
    } else if (error is FetchDataException) {
      var message = error.message;
      errorSnackBar(message.toString());
    } else if (error is ApiNotRespondingException) {
      errorSnackBar('Oops! It took longer to respond.');
    } else if (error is SomethingDataException) {
      var message = error.message;
      // ignore: avoid_print
      print(message);
    }
  }
}
