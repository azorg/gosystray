// File: "main.go"

package main

import (
	//"os"
	"log"
	_ "embed"

	"github.com/getlantern/systray"
)

//go:embed "icon.png"
var iconData []byte

func main() {
	systray.Run(onReady, onExit)
}

func onReady() {
	log.Print("onReady")

	systray.SetIcon(iconData)
	systray.SetTitle("Systray Test App")
	systray.SetTooltip("test app")

	mQuit := systray.AddMenuItem("Quit", "quit")
	mHello := systray.AddMenuItem("Hello", "log Hello")

	// Sets the icon of a menu item. Only available on Mac and Windows.
	mQuit.SetIcon(iconData)
	
	go func() {
		for {
			select {
			case <-mHello.ClickedCh:
				log.Print("Hello!")

			case <-mQuit.ClickedCh:
				systray.Quit()
				//myApp.Quit()
				log.Print("Quit")
				return
			} // select
		} // for
	}()
}

func onExit() {
	log.Print("onExit")
}

// EOF: "main.go"
