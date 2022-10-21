package main

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
)

func main() {

	if len(os.Args) < 3 {
		fmt.Println("请输入网址和文件")
		return
	}
	url := os.Args[1]
	fname := os.Args[2]

	rep, err := http.Get(url)

	if err != nil {
		fmt.Println(err)
		return
	}

	body, err := ioutil.ReadAll(rep.Body)
	if err != nil {
		fmt.Println(err)
		return
	}

	err = ioutil.WriteFile(fname, body, 0666)

	if err != nil {
		fmt.Println(err)
		return
	}
}
