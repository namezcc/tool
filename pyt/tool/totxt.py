# -*- coding: UTF-8 -*-

import xlrd
import os
import json

# import sys
# reload(sys)
# sys.setdefaultencoding('utf-8')

exlpath = []
isOutRow = 1  #是否导出控制行   0开始 
dataRow = 2

class OUT_TYPE:
    NO_OUT = 0
    OUT = 1

outpath = "./"

def ReadExl(fpath,name):
    if name.find(".xlsx") == -1:
        return
    fp = os.path.join(fpath,name)
    if os.path.isdir(fp):
        return
    book = xlrd.open_workbook(fp)
    for sh in book.sheets():
        if sh.name.find("Sheet") != -1:
            continue
        if name.find("String") != -1:
            ExlToOutAllLine(name,sh)
        else:
            ExlToJson(name,sh)
        break

def Init():
    global outpath
    f = open("config.json","rb")
    cfg = json.load(f)
    exlpath.extend(cfg["path"])
    outpath = cfg["outpath"]
    f.close()

def writetxt(fname,txt):
    global outpath
    fp = os.path.join(outpath,fname)
    f = open(fp,"wb")
    #f.write(txt.encode("UTF-8"))
    txt = txt.replace(u'\xa0',u' ')
    f.write(txt.encode("gbk"))
    f.close()
    print("write %s success\n" % fname)

def ExlToOutAllLine(fname,sheet):
    txt = ""
    for ri in range(0,sheet.nrows):
        for ci,cell in enumerate(sheet.row(ri)):
            try:
                v = cell.value
                if cell.ctype == 2:
                    if v % 1 == 0:
                        v = str(int(v))
                    else:
                        v = str(v)
                elif cell.ctype == 0 or cell.ctype == 5:   #空单元格
                    v = ""
                txt += "\t" + v
            except:
                print("error %s ******************* %s ------------------------- 第 %d 行 第 %d 列" % (fname,sheet.name,ri+1,ci+1))
                assert(0)
        txt += "\n"
    writetxt(sheet.name+".txt",txt)

def ExlToJson(fname,sheet):
    isOut = []
    outRow = sheet.row(isOutRow)
    for ci,cell in enumerate(outRow):
        try:
            isOut.append(int(cell.value))
        except:
            print("error %s ******************* %s ------------------------- 第 %d 行 第 %d 列" % (fname,sheet.name,isOutRow+1,ci+1))
            assert(0)

    txt = ""
    for r in range(dataRow,sheet.nrows):
        for ci,cell in enumerate(sheet.row(r)):
            try:
                if isOut[ci] == 0:
                    continue
                v = cell.value
                if cell.ctype == 2:
                    if v % 1 == 0:
                        v = str(int(v))
                    else:
                        v = str(v)
                elif cell.ctype == 0 or cell.ctype == 5:   #空单元格
                    v = ""
                if ci > 0:
                    txt += "\t"
                txt += v
            except:
                print("error %s *************** %s ---------------------------- 第 %d 行 第 %d 列" % (fname,sheet.name,r+1,ci+1))
                assert(0)
        txt += "\n"
    writetxt(sheet.name+".txt",txt)

def GetFiles(path):
    return  os.listdir(path)

def main():
    Init()
    for fpath in exlpath:
        lis = GetFiles(fpath)
        for f in lis:
            ReadExl(fpath,f)
    print("-------------- all success")

if __name__ == '__main__':
    main()