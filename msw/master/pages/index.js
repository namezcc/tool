import Link from 'next/link';
import styles from '../styles/Home.module.css';
import MyLayout from '../component/layout';
import {Layout,Button} from 'antd';
import { useSession, signIn, signOut } from "next-auth/react"

const { Footer } = Layout;

function Component() {
	const { data: session } = useSession()
	if(session) {
	  return <>
		已登录: {session.user.name} <br/>
		<Button type='primary' onClick={() => signOut({callbackUrl: '/'})}>退出</Button>
	  </>
	}
	return <>
	  未登录 <br/>
	  <Button type='primary' onClick={() => signIn(undefined,{callbackUrl: '/'})}>登录</Button>
	</>
}

export default function Home() {
  return (
	  <>
	  	<Footer>
			<Component></Component>
		  </Footer>
	  </>
  )
}
