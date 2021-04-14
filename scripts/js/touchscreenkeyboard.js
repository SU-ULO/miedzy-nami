let textfield = null;

let currentid = "";

function setup_touchscreen_keyboard()
{
	if(textfield != null) return true;
	if('ontouchstart' in window || navigator.maxTouchPoints > 0 || navigator.msMaxTouchPoints > 0)
	{
		textfield = document.createElement('input');
		textfield.type='text';
		textfield.onblur=()=>
		{
			end_input();
		}
		document.body.appendChild(textfield);
	}else return false;
	return true;
}

function start_input(id, text)
{
	if(textfield==null) return;
	textfield.value = text;
	textfield.focus();
	window.scrollTo(0, document.body.scrollHeight);
	currentid = id;
}

function end_input()
{
	currentid = "";
	if(textfield==null) return;
	textfield.blur();
	window.scrollTo(0, 0);
	textfield.value = "";
}

function poll_input()
{
	if(textfield==null) return null;
	return JSON.stringify([textfield.value, currentid]);
}