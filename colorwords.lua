local list = [[
aliceblue antiquewhite aqua aquamarine azure beige bisque black blanchedalmond
blue blueviolet brown burlywood cadetblue chartreuse chocolate coral
cornflowerblue cornsilk crimson cyan darkblue darkcyan darkgoldenrod darkgray
darkgreen darkgrey darkkhaki darkmagenta darkolivegreen darkorange darkorchid
darkred darksalmon darkseagreen darkslateblue darkslategray darkslategrey
darkturquoise darkviolet deeppink deepskyblue dimgray dimgrey dodgerblue
firebrick floralwhite forestgreen fuchsia gainsboro ghostwhite gold goldenrod
gray green greenyellow grey honeydew hotpink indianred indigo ivory khaki
lavender lavenderblush lawngreen lemonchiffon lightblue lightcoral lightcyan
lightgoldenrodyellow lightgray lightgreen lightgrey lightpink lightsalmon
lightseagreen lightskyblue lightslategray lightslategrey lightsteelblue
lightyellow lime limegreen linen magenta maroon mediumaquamarine mediumblue
mediumorchid mediumpurple mediumseagreen mediumslateblue mediumspringgreen
mediumturquoise mediumvioletred midnightblue mintcream mistyrose moccasin
navajowhite navy oldlace olive olivedrab orange orangered orchid palegoldenrod
palegreen paleturquoise palevioletred papayawhip peachpuff peru pink plum
powderblue purple rebeccapurple red rosybrown royalblue saddlebrown salmon
sandybrown seagreen seashell sienna silver skyblue slateblue slategray
slategrey snow springgreen steelblue tan teal thistle tomato turquoise violet
wheat white whitesmoke yellow yellowgreen transparent currentcolor
]]

local colors = {}
for c in list:gmatch("%S+") do
	colors[c] = true
end

function Div(el)
	if not el.classes:includes("colorwords") then
		return nil
	end
	return el:walk({
		Str = function(s)
			local pre, word, post = s.text:match("^(%p*)(%a+)(%p*)$")
			if not (word and colors[word:lower()]) then
				return nil
			end
			local name = word:lower()

			local pad = "padding:2px 6px; border-radius:4px; "
			local span

			if name == "transparent" then
				-- nothing to fill, so show a dashed box
				span = pandoc.Span(
					{ pandoc.Str(word) },
					pandoc.Attr("", {}, { style = pad .. "outline:1px dashed #888;" })
				)
			elseif name == "currentcolor" then
				-- background = the current text color, inner text flipped to white
				local inner = pandoc.Span({ pandoc.Str(word) }, pandoc.Attr("", {}, { style = "color:#fff;" }))
				span = pandoc.Span({ inner }, pandoc.Attr("", {}, { style = pad .. "background-color:currentcolor;" }))
			else
				-- black fallback first, then auto black/white text based on lightness
				local style = pad
					.. "background-color:"
					.. name
					.. "; "
					.. "color:#000; "
					.. "color:oklch(from "
					.. name
					.. " clamp(0, (l - 0.7) * -1000, 1) 0 0);"
				span = pandoc.Span({ pandoc.Str(word) }, pandoc.Attr("", {}, { style = style }))
			end

			local out = pandoc.Inlines({})
			if pre ~= "" then
				out:insert(pandoc.Str(pre))
			end
			out:insert(span)
			if post ~= "" then
				out:insert(pandoc.Str(post))
			end
			return out
		end,
	})
end
