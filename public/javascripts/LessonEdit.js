$(document).ready(function() {
    
    loadAndPlayVideo(getYoutubeID("http://www.youtube.com/watch?v=7MqkEZn8pN4", "v"), 0, 0, "video-player", 0);

    $("#load-video").click(function() {
      var video_url = $("#load_video_url").val();
      var video_id = getYoutubeID(video_url, 'v');
      $("#current_video_url").text('Video URL: ' + video_url.split('&')[0]);
      loadAndPlayVideo(video_id, 0, 0, "video-player", 0);
      return false;
    });

    $(".start-sync").click(function(){
        var time = parseInt(ytplayer.getCurrentTime());
        var parent_node = $(this).parentsUntil('table')[1];
        $(parent_node).children('td').children("#start_time").val(time);
        return false;
    });

    $(".end-sync").click(function(){
        var time = parseInt(ytplayer.getCurrentTime());
        var parent_node = $(this).parentsUntil('table')[1];
        $(parent_node).children('td').children("#end_time").val(time);
        return false;
    });

    $("#lesson-edit-tabs").tabs();
    newNoteSubmit();
    newQuizSubmit();
    afterEventLoad(); 
});


// Binds an ajax submit to the note form
var newNoteSubmit = function() {
   $("#new_note").unbind('submit');
   $("#new_note").submit(function(){
        var video_url = ytplayer.getVideoUrl();
        var lesson_id = $("#lesson_id").val();

        $("#video_url").val(video_url);

        var data = $("#new_note").serialize();


        $.post('/notes/', data, function(data){ 
          $("#note-error-message").text(data);
          if (data == 'Error.') return false;
          $(':input','#new_note').not(':button, :submit, :reset, :hidden').val('');   
        });

        $("#events-area").load('/lessons/' + lesson_id + '/events/', afterNoteLoad);
        return false;
    });
}

var newQuizSubmit = function() {
   $("#new_quiz").unbind('submit');
   $("#new_quiz").submit(function(){
        var video_url = ytplayer.getVideoUrl();
        var lesson_id = $("#lesson_id").val();
        var course_id = $("#course_id").text();
        $("#video_url").val(video_url);

        var data = $("#new_quiz").serialize();
        $.post('/courses/' + course_id + '/quizzes/', data, function(data){ 
          $("#quiz-error-message").text(data);
          if (data == 'Error.') return false;
          $(':input','#new_quiz').not(':button, :submit, :reset, :hidden').val('');
        });

        $("#events-area").load('/lessons/' + lesson_id + '/events/');
        return false;
    });
}

// Binds event edit to load edit forms
var afterEventLoad = function() {
 $('.edit-note').click(function(){
      $("#lesson-edit-tabs").tabs('select', 0);
      $("a[href=#add-note]").text('Edit note');
      $("#lesson-edit-tabs").tabs('disable', 1);
      var data_div = $(this).parent().children(".data");
      var note_content = $(this).parent().children(".content").text();
      var event_video_id = getYoutubeID(data_div.attr("data-video"), "v");
      var event_video_start_time = data_div.attr("data-start_time");
      var event_video_end_time = data_div.attr("data-end_time");
      $("#current_video_url").text('Video URL: ' + data_div.attr("data-video").split('&')[0]);

      if ( event_video_id == getYoutubeID(ytplayer.getVideoUrl(),"v")) {
        ytplayer.seekTo(event_video_start_time, true);
      } else {
        loadAndPlayVideo( event_video_id, event_video_start_time, 0, "video-player", 1);
      } 
      $("#load_video_url").val(data_div.attr("data-video"));
      $("#note_content").val(note_content);
      $("#start_time").val(event_video_start_time);
      $("#end_time").val(event_video_end_time);
      editNoteSubmit(data_div.attr("data-id"));
      return false;
    });

   $('.edit-quiz').click(function(){
       $("#lesson-edit-tabs").tabs('select', 1);
       $("a[href=#add-quiz]").text('Edit quiz');
       $("#lesson-edit-tabs").tabs('disable', 0);
       var course_id = $("#course_id").text();
      
       var data_div = $(this).parent().children(".data");
       var quiz_id = data_div.attr("data-id");

       var quiz_question = $(this).parent().children(".question").text();
       var event_video_id = getYoutubeID(data_div.attr("data-video"), "v");
       var event_video_start_time = data_div.attr("data-start_time");
       var event_video_end_time = data_div.attr("data-end_time");
       $("#current_video_url").text('Video URL: ' + data_div.attr("data-video").split('&')[0]);

       if ( event_video_id == getYoutubeID(ytplayer.getVideoUrl(),"v")) {
       ytplayer.seekTo(event_video_start_time, true);
       } else {
       loadAndPlayVideo( event_video_id, event_video_start_time, 0, "video-player", 1);
       } 
       $("#load_video_url").val(data_div.attr("data-video"));
       $("#add-quiz").load('/courses/' + course_id + '/quizzes/' + quiz_id + '/edit.js/', 
         function(){
          $('#quiz_component_tokens').unbind();
      $('#quiz_component_tokens').tokenInput('/components.json?course_id=' + course_id,
      { 
        crossDomain: false,
        prePopulate: $('#quiz_component_tokens').data('pre')
      });
      console.log(event_video_start_time);
      console.log( $(".edit_quiz #start_time"));
      $(".edit_quiz #start_time").val(event_video_start_time);
      $(".edit_quiz #end_time").val(event_video_end_time);
         }); 
        editQuizSubmit(quiz_id); 
       return false;
   });

}

var editQuizSubmit = function(quiz_id) {
  $(".edit_quiz").unbind('submit');
  $(".edit_quiz").submit(function(){
        var video_url = ytplayer.getVideoUrl();
        var lesson_id = $("#lesson_id").val();

        $("#video_url").val(video_url);
        //$("#video_url").attr('type', 'text');
        
        var data = $("#new_quiz").serialize();
        $.ajax({
                type: "PUT",
                url: '/courses/' + course_id + '/' + quiz_id + '/',
                data:  data ,
                dataType: 'html',
                success: function(msg) {
                  $("a[href=#add-note]").text('Add note');
                  $("#lesson-edit-tabs").tabs('enable', 1);
                  $(':input','#new_quiz').not(':button, :submit, :reset, :hidden').val('');
                  newQuizSubmit();
                },
                error: function(msg){ alert(msg); } 
              });

        $("#events-area").load('/lessons/' + lesson_id + '/events/', afterNoteLoad);
        return false;
    });
}

var editNoteSubmit = function(note_id) {
  $("#new_note").unbind('submit');
  $("#new_note").submit(function(){
        var video_url = ytplayer.getVideoUrl();
        var lesson_id = $("#lesson_id").val();

        $("#video_url").val(video_url);
        //$("#video_url").attr('type', 'text');
        
        var data = $("#new_note").serialize();
        $.ajax({
                type: "PUT",
                url: '/notes/' + note_id + '/',
                data:  data ,
                dataType: 'html',
                success: function(msg) {
                  $("a[href=#add-note]").text('Add note');
                  $("#lesson-edit-tabs").tabs('enable', 1);
                  $(':input','#new_note').not(':button, :submit, :reset, :hidden').val('');
                  newNoteSubmit();
                },
                error: function(msg){ alert(msg); } 
              });

        $("#events-area").load('/lessons/' + lesson_id + '/events/', afterNoteLoad);
        return false;
    });
}
