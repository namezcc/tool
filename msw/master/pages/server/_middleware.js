import {NextRequest,NextResponse } from 'next/server'
import {getToken} from "next-auth/jwt"

export async function middleware(req) {
    //获取token
	const { pathname, origin } = req.nextUrl;
    const session = await getToken({
        req,
        secret: process.env.SECRET,
    })
    //未授权，跳转到登录页面
    if (!session) {
        return NextResponse.redirect(origin+'/login')
    } else {
        NextResponse.next()
    }
}