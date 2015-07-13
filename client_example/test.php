<?
session_start();
// You need a unique string that identifies the user. The easiest way is to
// simply use the session ID. But because sending session IDs to other servers
// can be a security problem, we use only a part of the session ID here.
// This is still a quasi-unique string, so it works just as well.
$captcha_id = substr(session_id(), 0, 15); // first 15 characters of the session ID
?>

<html><head></head><body>
<img src="//captchator.com/captcha/image/<?= $captcha_id ?>" />
<br />
Please enter the text from the picture:
<form action="test.php" method="post">
<input type="text" name="captcha_answer" />
<input type="submit" name="submit" value="Check" />
</form>

<?
if ($_POST['captcha_answer']) {
  // remove anything except letters and numbers (security)
  $answer = preg_replace('/[^a-z0-9]+/i', '', $_POST['captcha_answer']);
  // check answer
  // file() with URLs may not supported by your PHP configuration. In this case, you need to use another HTTP client library.
  if (implode(file("http://captchator.com/captcha/check_answer/".$captcha_id."/".$answer)) == '1') {
    echo '<div style="color: green">Answer correct!</div>';
  } else {
    echo '<div style="color: red">Wrong answer, please try again.</div>';
  }
}
?>

<p>
See the <a href="test.php.txt">source code</a> of this script.
</p>

</body></html>
