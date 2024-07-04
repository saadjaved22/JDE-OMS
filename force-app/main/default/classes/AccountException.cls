/**
 * @author piotr.tugeman@emark.com
 */
public class AccountException extends Exception {
  private Account account;

  public AccountException(Account account, String message) {
    this(message);
    this.account = account;
  }

  public Account getAccount() {
    return this.account;
  }
}
