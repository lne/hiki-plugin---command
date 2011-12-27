#
# Plugin for hiki.
#
# <<<$ - >>> is defined in this file.
#
# Created at: 2011/12/19 12:00:00
# Author: Dongfeng Wei <lnlne_1981@hotmail.com>
#
class ::HikiDoc

  private

  CMD_OPEN  = /&lt;&lt;&lt;\$/
  CMD_CLOSE = /&gt;&gt;&gt;/

  #
  # Extension of block_parser.
  #
  alias __block_parser__ block_parser

  def block_parser( text )
    ret = text
    if CMD_OPEN =~ ret
      ret = parse_cmd( ret )
      ret = __block_parser__( ret )
      "#{cmd_style}\n#{cmd_action}\n#{ret}\n"
    else
      __block_parser__( ret )
    end
  end

  #
  # Parse <<<$ >>>
  #
  def parse_cmd( text )
    ret = text
    ret.gsub!( /^#{CMD_OPEN}$(.*?)^#{CMD_CLOSE}$/m ) do |str|
      lines = $1.strip.split("\n")
      lines.map! do |line|
        case line
        when /^\s*$/
          "<li><span> </span></li>"
        when /^\s*\#/
          "<li><span class='com'>#{line}</span></li>"
        when /^(.+)(\#.*)$/
          "<li><span onclick='selectCmd(this);'>#{$1}</span><span class='com'>#{$2}</span></li>"
        else
          "<li><span onclick='selectCmd(this);'>#{line}</span></li>"
        end
      end
      "\n<ul type='none' class='cmd'> #{lines.join('')} </ul>\n\n"
    end
    ret
  end

  def cmd_style
    <<'EOS'
<style type="text/css">
ul.cmd {
border-style:solid;
border-color:#cccccc;
border-width:1px 1px 1px 6px;
margin:10px 0px 16px 32px;
padding:8px;
background-color:#f0f0ff;
}
ul.cmd li {
white-space:pre;
list-style-type: none;
}
ul.cmd li span.com { color:#808080; font-style:oblique;}
</style>
EOS
  end

  def cmd_action
    <<'EOS'
<script type="text/javascript">
function selectCmd(span) {
var t = span.innerHTML
t = t.replace(/\s+$/, "");
while ( t.indexOf("&amp;",0) != -1 ) {
t = t.replace("&amp;", "&")
}
while ( t.indexOf("&lt;",0) != -1 ) {
t = t.replace("&lt;", "<")
}
while ( t.indexOf("&gt;",0) != -1 ) {
t = t.replace("&gt;", ">")
}
var length = t.length
// FF,chrome,...
if (window.getSelection) {
var range = document.createRange();
range.setStart(span.firstChild,0);
range.setEnd(span.firstChild,length);
var sel = getSelection();
sel.removeAllRanges();
sel.addRange(range);
} else {
// IE
var range = document.selection.createRange();
range.moveToElementText(span);
range.collapse();
range.moveStart("character", 0);
range.moveEnd("character", length);
range.select();
clipboardData.setData('Text', t);
}
}
</script>
EOS
  end
end
