$(function () {

	function copyToClipboard( elementId ) {
		var $temp = $( "<input>" ).val( $( "#" + elementId ).text() );
		$( "body" ).append($temp);
		$temp.select();
		document.execCommand("copy");
		$temp.remove();
	}

	$("a.copy-key").click(function () {
		copyToClipboard($(this).data('clipboard-target'));
	});

	// toggle label display between actual passwords and *****
	/*$('td.key-password-column label').click(function () {
      $(this).parents("td:first").find('label').toggle();
    });*/
	$('label[id*="plain_pass"]').click(function () {
		exchangePassword($(this));
	});

	$('label[id*="plain_pass"]').each(function(){
		$(this).prev().click(function(){
			exchangePassword($(this).next());
		});
	});

	function exchangePassword(hiddenLabel){
		hiddenLabel.toggle();
		hiddenLabel.prev().toggle();
	}
});