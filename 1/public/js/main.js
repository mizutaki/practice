function openEditWindow(thread_id) {
  var wx = 640;
  var wy = 480;
  var x = (screen.height - wx) / 2;
  var y = (screen.height - wy) / 2;
  window.open('/edit_thread/' + thread_id, null, "width=" + wx +",height=" + wy + ",top=" + y + ", left=" + x);
}

function openReplyWindow(thread_id) {
  var wx = 640;
  var wy = 480;
  var x = (screen.height - wx) / 2;
  var y = (screen.height - wy) / 2;
  window.open('/reply_thread/' + thread_id, null, "width=" + wx +",height=" + wy + ",top=" + y + ", left=" + x);
}

function deleteThread(thread_id) {
  if (window.confirm('削除しますか?')) {
    var form  =document.createElement('form');
    document.body.appendChild(form);
    var input = document.createElement('input');
    input.setAttribute('type', 'hidden');
    input.setAttribute('name', 'delete_thread');
    input.setAttribute('value', thread_id);
    form.appendChild(input);
    form.setAttribute('action', '/delete_thread/' + thread_id);
    form.setAttribute('method', 'post');
    form.submit();
  } else {
    return false;
  }
}

function deleteAccount(current_login_user) {
  var delete_user = $("#delete_user").val();
  var delete_user_password = $("#delete_user_password").val();
  if (current_login_user === delete_user) {
    $.ajax({
      type: "POST",
      url: "/delete_account",
      data: {
        login_user: delete_user,
        login_password: delete_user_password
      },
      dataType: 'html'
    }).done(function(data) {
      alert("delete OK");
      document.location = "/";
    }).fail(function(data) {
      alert("delte ERROR");
    }
    );
  } else {
    alert("You can not delete other than your own");
  }
}