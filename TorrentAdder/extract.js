// #mainSearchTable > tbody >> a.cellMainLink

function getClass(obj) {
    if (typeof obj === "undefined")
        return "undefined";
    if (obj === null)
        return "null";
    return Object.prototype.toString.call(obj)
    .match(/^\[object\s(.*)\]$/)[1];
}

var table = document.getElementById('mainSearchTable');
var items = table.getElementsByClassName('torrentname');

var itemsParsed = new Array();
for (var i = 0; i < items.length; ++i)
{
    var item = items[i];
    var nameElement = item.getElementsByClassName('cellMainLink')[0];
    var infoColumn = item.parentElement;
    
    var magnet = null;
    var links = infoColumn.getElementsByClassName('iaconbox')[0];
    links = links.getElementsByTagName('a');
    for (var j = 0; j < links.length; ++j)
    {
        var link = links[j].getAttribute('href');
        if (link.indexOf('magnet') === 0)
        {
            magnet = link;
            break;
        }
    }
    
    var size  = null;
    var age   = null;
    var seed  = null;
    var leech = null;
    
    var columns = infoColumn.parentElement.children;
    for (var j = 0; j < columns.length; ++j)
    {
        if (columns[j] == infoColumn)
        {
            size  = columns[j+1].innerText;
            age   = columns[j+3].innerText;
            seed  = columns[j+4].innerText;
            leech = columns[j+5].innerText;
            break;
        }
    }
    itemsParsed.push({'name':nameElement.innerText, 'magnet':magnet, 'size':size, 'age':age, 'seed':seed, 'leech':leech});
}
JSON.stringify(itemsParsed);
