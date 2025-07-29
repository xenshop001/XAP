$(function () {
    let selectedPlayer = null;

    function display(show) { show ? $('.panel-container').fadeIn(300) : $('.panel-container').fadeOut(300); }
    display(true);

    window.addEventListener('message', function (event) {
        const item = event.data;
        if (item.type === 'show') display(true);
        if (item.type === 'hide') display(false);
        if (item.type === 'updatePlayerList') updatePlayerList(item.players);
        if (item.type === 'updateLog') updateLog(item.log);
        if (item.type === 'appendLog') appendLog(item.entry);
    });

    $('.tab-button').on('click', function() {
        $('.tab-button').removeClass('active');
        $(this).addClass('active');
        $('.tab-content').removeClass('active');
        $('#' + $(this).data('tab')).addClass('active');
    });
    
    function updatePlayerList(players) {
        $('#player-list').empty();
        players.forEach(player => {
            $('#player-list').append(
                `<li class="player-item" data-id="${player.id}" data-name="${player.name}"><span>[${player.id}] ${player.name}</span></li>`
            );
        });
    }

    function updateLog(log) {
        const logContainer = $('.log-container');
        logContainer.empty();
        log.forEach(entry => appendLog(entry, false));
    }

    function appendLog(entry, animate = true) {
        const logContainer = $('.log-container');
        const logHtml = `<div class="log-entry" data-type="${entry.type}" style="display: ${animate ? 'none' : 'block'};">
                            <span class="time">[${entry.time}]</span>
                            <span class="message">${entry.msg}</span>
                         </div>`;
        const newEntry = $(logHtml);
        logContainer.prepend(newEntry);
        if (animate) { newEntry.slideDown(300); }
    }

    $(document).on('click', '.player-item', function() {
        selectedPlayer = { id: $(this).data('id'), name: $(this).data('name') };
        $('.player-item').removeClass('selected');
        $(this).addClass('selected');
        $('.placeholder').hide();
        $('#selected-player-name').text(`[${selectedPlayer.id}] ${selectedPlayer.name}`);
        $('.actions-container').show();
        $('.tab-button[data-tab="actions"]').click(); 
    });

    $('.action-btn').on('click', function() {
        if (!selectedPlayer) return;
        $.post(`https://adminpanel/performAction`, JSON.stringify({ action: $(this).data('action'), target: selectedPlayer.id }));
    });

    $('.self-actions button').on('click', function() {
        $.post(`https://adminpanel/performSelfAction`, JSON.stringify({ action: $(this).data('action') }));
    });
    
    $('#search-bar').on('keyup', function() {
        let value = $(this).val().toLowerCase();
        $("#player-list li").filter(function() {
            $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
    });

    $(document).keyup(e => e.keyCode === 27 && $.post('https://adminpanel/closePanel'));
});