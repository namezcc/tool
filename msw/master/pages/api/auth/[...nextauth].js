import NextAuth from "next-auth"
import CredentialsProvider from 'next-auth/providers/credentials'
import {getUser} from "../usercheck";

//配置next-auth，参考https://next-auth.js.org/configuration/options

export const authOptions = {
    // provider配置凭证登录
    providers: [
        CredentialsProvider({
            name: 'login',
            async authorize(credentials, req) {//具体授权逻辑
                const user = await getUser(credentials.userName,credentials.password)
                if(user?.res == 1){
                    return {name:user.username}
                }
                return {status:'reject'}
            }
        })
    ],
    secret: process.env.SECRET,

    session: {
        strategy: "jwt",
    },
    jwt: {},
    pages: {//自定义界面 ，可配置signIn，signOut，error，verifyRequest，newUser
        signIn: '/login',
    },
    callbacks: {//回调函数
        async signIn({ user, account, profile, email, credentials }) {
			console.log("singin ...")
            //登录回调，如果authorize不成功，重定向到login界面，并附带错误信息参数
            if(user?.status === 'reject'){
                return "/login?msg=err"
            }
            return true
        },
		// async redirect({ url, baseUrl }) {
		// 	console.log("url ---------")
		// 	console.log(url)
		// 	console.log(baseUrl)
		// 	return baseUrl
		// },
        // async redirect({ url, baseUrl }) {//不设置回调，直接默认使用url
        // url一般为被中间件拦截之前的目标url，例如：localhost:3000/management/index，baseurl为localhost:3000，如果url不包含baseUrl，大概率是signIn回调函数重定向页面
        //   if (url.startsWith(baseUrl)) return url
        //   else if (url.startsWith("/")) return new URL(url, baseUrl).toString()
        // },
		// async jwt({token, user, account, profile, isNewUser}) {
		// 	console.log("get jwt")
		// 	console.log(token)
		// 	console.log(user)
        //     return token
        // },

        // async session({session, token, user}) {
		// 	console.log("get session")
		// 	console.log(session)
		// 	console.log(token)
        //     return session
        // },
    },
    events: {},
    debug: false,
}

export default NextAuth(authOptions)