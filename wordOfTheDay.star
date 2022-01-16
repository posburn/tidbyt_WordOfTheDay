"""
Applet: WordOfTheDay
Summary: Displays the word of the day
Description: Fetches the word of the day from the Merriam-Webster website and displays it
Author: Paul Osburn
"""

load("render.star", "render")
load("http.star", "http")
load("re.star", "re")
load("cache.star", "cache")

# Constants
CACHE_KEY = "saved_doc"
SITE_URL = "https://www.merriam-webster.com/word-of-the-day"

def main():
    # Check the cache first
    doc_cached = cache.get(CACHE_KEY)
    if doc_cached != None:
        doc = doc_cached
    else:
        # Otherwise fetch the web page
        rep = http.get(SITE_URL)
        if rep.status_code != 200:
            # Fail silently and display nothing
            doc = ""
        else:
            doc = rep.body()
            cache.set(CACHE_KEY, doc, ttl_seconds=240)

    # Word
    start = doc.find("<h1>") + 4
    end = doc.find("</h1>")
    word = doc[start:end].capitalize()

    # Definition
    def_start_token = "<h2>What It Means</h2>"
    def_start = doc.find(def_start_token) + len(def_start_token)
    def_end = doc.find("// ") - 10
    txt = doc[def_start:def_end]
    txt = txt.replace("<p>","").replace("</p>","")
    txt = txt.replace("<em>","").replace("</em>","")
    txt = txt.replace("// ","").replace("\"","")
    txt = txt.replace("</a>","")
    txt = txt.replace(word + " means ", "")
    
    # Remove anchor tags
    pattern = "<a[^>]*>"
    txt = re.sub(pattern, "", txt)

    definition = txt.lstrip().capitalize()
    
    return render.Root(
        delay = 100,
        child = render.Column(
            children = [
                render.Text(content = word, color = "#FFF"),
                render.Box(width = 64, height = 1, color = "#811"),
                render.Box(width = 64, height = 1, color = "#400"),
                render.Marquee(
                    height = 23,
                    offset_start = 23,
                    offset_end = 23, 
                    scroll_direction = "vertical",
                    child = render.WrappedText(
                        content = definition, 
                        font = "tom-thumb", 
                        color = "#A0A0D0")
                )
            ],
        )
    )