function openWindow(thread_id) {
  var wx = 640;
  var wy = 480;
  var x = (screen.height - wx) / 2;
  var y = (screen.height - wy) / 2;
  window.open('/edit_thread/' + thread_id, null, "width=" + wx +",height=" + wy + ",top=" + y + ", left=" + x);
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