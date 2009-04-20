function seinfeldBadge() {
   $(".seinfeld-badge").each(function() {
        var seinfeld = $(this);
        var username = seinfeld.attr("class").replace(/.*user-([a-z0-9]+).*/gi, "$1");
       
        $.getJSON("http://pipes.yahoo.com/pipes/pipe.run?_id=6ff23978d8e18aa8f62b196cd7d0fe78&_render=json&username=" + username + "&_callback=?", function(calendar){
            var table = $("<div id=\"calendar\"/>").html(calendar.value.items[0].content);
            table.find("thead th:contains('Month')").remove();
            $("th.monthName", table).attr("colspan", "8");
            seinfeld.append(table);

            $("td.progressed", table).each(function(){
             var that = $(this);
             var x = $("<div class=\"xmarksthespot\"/>").css("height", that.height())
                                                        .css("width", that.width())
                                                        .append("<img src=\"http://calendaraboutnothing.com/images/x_1.png\" height=\"80%\" width=\"50%\">");
             that.append(x);
            });
        });

        $.getJSON("http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20html%20where%20url%3D%22http%3A%2F%2Fwww.calendaraboutnothing.com%2F~" + username + "%22%20and%20xpath%3D'%2F%2Fdiv%5B%40id%3D%22stats%22%5D%2Fdiv'%0A%20%20%20%20&format=json&callback=?", function(data){
            var currentStreak = $("<strong>Current Streak: </strong>").append("<em>"+ data.query.results.div[0].span[1].content + "</em>");
            var longestAnchor = $("<a/>").attr("href", data.query.results.div[1].a.href).text(data.query.results.div[1].a.span[1].content);
            var longestStreak = $("<strong class=\"longest\">Longest Streak: </strong>").append(longestAnchor);
            var streaks = $("<p class=\"streaks\"/>").append(currentStreak)
                                                     .append(longestStreak);
            seinfeld.append(streaks);
            seinfeld.append($("<p class=\"pimpage\"><a href=\"http://github.com/lachlanhardy/seinfeld-badge\">Want your own badge?</a></p>"));
        });
    });
}