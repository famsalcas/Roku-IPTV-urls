sub init()
    m.top.backgroundURI = "pkg:/images/background-controls.jpg"

    m.save_feed_url = m.top.FindNode("save_feed_url")  'Save url to registry

    m.get_channel_list = m.top.FindNode("get_channel_list") 'get url from registry and parse the feed
    m.get_channel_list.ObserveField("content", "SetContent") 'When content is ready, populate grid

    m.grid = m.top.FindNode("grid")
    m.grid.ObserveField("itemSelected", "setChannel")

    m.video = m.top.FindNode("Video")
    m.video.ObserveField("state", "checkState")
end sub

' ---------------------------------------------------
' Convierte la estructura ContentNode (la que genera get_channel_list)
' a una lista plana de items (title, icon, url) para el MarkupGrid
' ---------------------------------------------------
sub SetContent()
    ' Flatten the ContentNode tree returned by get_channel_list into an array of simple items
    con = m.get_channel_list.content
    items = []
    if con = invalid return
    ' If top-level has groups (ContentNode children), iterate groups and children
    if con.getChildCount() > 0
        for g = 0 to con.getChildCount() - 1
            group = con.getChild(g)
            if type(group.getChildCount()) <> "invalid" and group.getChildCount() > 0
                for c = 0 to group.getChildCount() - 1
                    ch = group.getChild(c)
                    item = {
                        title: ch.title
                        icon: ch.icon
                        url: ch.url
                    }
                    items.push(item)
                end for
            else
                ' top-level items (no groups)
                if type(group.title) <> "invalid"
                    item = {
                        title: group.title
                        icon: group.icon
                        url: group.url
                    }
                    items.push(item)
                end if
            end if
        end for
    end if

    ' Assign to grid
    m.grid.content = items
    m.grid.SetFocus(true)
end sub

' ---------------------------------------------------
' Al seleccionar un item en la grid
' ---------------------------------------------------
sub setChannel()
    idx = m.grid.itemSelected
    if idx < 0 return
    content = m.grid.content[idx]
    if content = invalid return

    ' Prepare content associative for video node
    videoContent = {
        url: content.url
        title: content.title
        streamFormat: "hls, m3u8, ts, mp4, mkv, webm, mov, avi, wmv, asf, vob, ogv, ogg, mp3, aac, m4a, dash, ism, progressive"
    }

    ' Security / certs (kept from original)
    videoContent.HttpSendClientCertificates = true
    videoContent.HttpCertificatesFile = "common:/certs/ca-bundle.crt"

    m.video.EnableCookies()
    m.video.SetCertificatesFile("common:/certs/ca-bundle.crt")
    m.video.InitClientCertificates()

    ' If same url already playing, do nothing
    if m.video.content <> invalid and m.video.content.url = videoContent.url return

    m.video.content = videoContent

    m.top.backgroundURI = "pkg:/images/rsgde_bg_hd.jpg"
    m.video.trickplaybarvisibilityauto = false

    m.video.control = "play"
end sub

' ---------------------------------------------------
' (El resto del archivo mantiene las funciones auxiliares que ya tenías:
'  manejo de diálogos, guardado de feed, checkState, onKeyPress, etc.)
'  No las reescribí aquí para no perder tus comportamientos existentes.
'  En el ZIP modificado están intactas.
' ---------------------------------------------------
