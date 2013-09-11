var I3D = I3D || {};

I3D.Main = (function (window, document) {
	var _$loginButton,
		_$loginPanel;

	var _bindExternalLinks = function() {
		$('a[rel*=external]').click(function(){
			window.open($(this).attr('href'));
			return false; 
		});
	};

	var _cacheSelectors = function() {
		_$loginButton = $('#login');
		_$loginPanel = $('#login_panel');
	};

	var _initLoginForm = function() {
		if(_$loginButton.length == 0) return;  //user logged in

		_$loginButton.on('mouseover', function() {
			_$loginPanel.removeClass('hidden');
		}).on('mouseout', function() {
			_$loginPanel.addClass('hidden');
		});
	};

	var self = {
		init: function() {
			_bindExternalLinks();
			_cacheSelectors();
			_initLoginForm();
		}
	};

	return self;
})(this, this.document);

$(document).ready(function(){
	I3D.Main.init();
});