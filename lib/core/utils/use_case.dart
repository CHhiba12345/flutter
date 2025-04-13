///
/// interface Usecase will handle the Usecase in domain repository
/// as Paramatre will be of any Type [any] and will return any type [any]
///
abstract class UseCase<T, Params> {
  T call(Params params);
}
