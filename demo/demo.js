!function(){
    document.addEventListener('DOMContentLoaded', function(){
        var letters = document.getElementsByTagName('h1'),
            demos = document.getElementsByClassName('demo');

        for(var i = 0, l = letters.length; i < l; i++){
            new Maskew(letters[i], 6, { touch: true, anchor: 'bottom', showElement: 'inline-block' });
        }
        for(i = 0, l = demos.length; i < l; i++){
            new Maskew(demos[i], 12, { touch: true });
        }

    }, false);
}();
