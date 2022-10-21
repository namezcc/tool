package test

import (
	"bytes"
	"container/list"
	"fmt"
	"hash/crc32"
	"math/rand"
	"sync"
	"testing"
	"time"
)

func Test_Example(t *testing.T) {

	buf := new(bytes.Buffer)
	for i := 'a'; i <= 'z'; i++ {
		buf.WriteRune(i)
	}
	for i := 'A'; i <= 'Z'; i++ {
		buf.WriteRune(i)
	}
	for i := '0'; i <= '9'; i++ {
		buf.WriteRune(i)
	}

	str := buf.String()
	// fmt.Println(buf.String())
	// fmt.Println(byte(str[5]))

	const ARR_NUM uint32 = 32
	var arrnum [ARR_NUM]uint32
	var multnum = (^uint32(0)) / ARR_NUM
	var num = 100000

	for i := 0; i < num; i++ {
		var rlen = rand.Intn(11) + 5
		buf.Reset()
		for j := 0; j < rlen; j++ {
			buf.WriteByte(str[rand.Intn(len(str))])
		}

		_hval := crc32.ChecksumIEEE(buf.Bytes())
		// arrnum[_hval%32]++
		arrnum[_hval/multnum]++
	}

	for i := uint32(0); i < ARR_NUM; i++ {
		fmt.Printf("index %d num -> %d\n", i, arrnum[i]*100/uint32(num))
	}
}

type TestCall struct {
	_i   int
	_map map[int]int
}

func (_t *TestCall) callClass() {
	fmt.Println(_t._i)
}

type callback func()

func Test_2(t *testing.T) {

	_eee := TestCall{}
	fmt.Println("mmm", _eee._map)

	_map := make(map[int]*list.List)
	_map[1] = new(list.List)
	l1 := _map[1]
	l1.PushBack(111)

	l2 := _map[1]
	fmt.Println(l2.Front().Value)
}

func Test_3(t *testing.T) {
	// var eve gnet.EventHandler = &gnet.EventServer{}
	// gnet.Serve(eve, "tcp://127.0.0.1:11111")

	ws := sync.WaitGroup{}

	_sc := make(chan int, 10)
	ws.Add(1)

	go func() {
		for i := 0; i < 20; i++ {
			_sc <- i
		}
		close(_sc)
		ws.Done()
	}()

	ws.Add(1)
	go func() {
		for v := range _sc {
			fmt.Println(v)
		}
		fmt.Println("chan close")
		ws.Done()
	}()

	ws.Wait()
}

type handlecall func()

var _hand = make([]handlecall, 5)

func (_t *TestCall) init() {
	_hand = append(_hand, _t.callClass)
}

func Test_call(t *testing.T) {
	{
		t1 := TestCall{
			_i: 1,
		}

		t2 := TestCall{
			_i: 2,
		}

		t1.init()
		t2.init()
	}

	for _, v := range _hand {
		if v != nil {
			v()
		}
	}
}

type base struct {
}

func (*base) call() {
	fmt.Println("base")
}

type sa struct {
	base
}

func (t *sa) call() {
	// fmt.Println("sa")
	t.base.call()
}

func Test_struct_call(t *testing.T) {
	a := sa{}
	a.call()
	// a.base.call()
	fmt.Println(time.Now().Format("2006-01-02 15:04:05"))
}
