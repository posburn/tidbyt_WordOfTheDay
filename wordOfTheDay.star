load("render.star", "render")
load("http.star", "http")
load("re.star", "re")

def main():
    rep = http.get("https://www.merriam-webster.com/word-of-the-day")
    if rep.status_code != 200:
        fail("Request failed with status %d", rep.status_code)

    doc = rep.body()

    # Word
    start = doc.find("<h1>") + 4
    end = doc.find("</h1>")
    word = doc[start:end].capitalize()
    wordLen = len(word)

    # Definition
    defStartToken = "<h2>What It Means</h2>"
    defStart = doc.find(defStartToken) + len(defStartToken)
    defEnd = doc.find("// ") - 10
    txt = doc[defStart:defEnd]
    txt = txt.replace("<p>","").replace("</p>","")
    txt = txt.replace("<em>","").replace("</em>","")
    txt = txt.replace("// ","").replace("\"","")
    txt = txt.replace("</a>","")
    
    # Remove anchor tags
    pattern = "<a[^>]*>"
    txt = re.sub(pattern, "", txt)

    definition = txt.lstrip().capitalize()
    
    return render.Root(
        delay = 100,
        child = render.Column(
            children = [
                render.Text(content = word, color = "#FFF"),
                render.Box(width = 64, height = 2, color = "#511",),
                render.Marquee(height = 30, scroll_direction = "vertical",
                    child = render.WrappedText(
                        content = definition, 
                        font = "tom-thumb", 
                        color = "#A0A0D0")
                )
            ],
        )
    )
