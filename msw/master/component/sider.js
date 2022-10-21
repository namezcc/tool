import Link from 'next/link'
import {Button,Menu} from 'antd'

function Mitem(p) {
	return (
		<Menu.Item eventKey={p.k} >
			<Link href={p.a} passHref>
				<Button type='link' block>
					{p.name}
				</Button>
			</Link>
		</Menu.Item>
	)
}

export default function Sider() {
	return (
		<>
			<Menu 
				defaultSelectedKeys={["1"]}
				mode='inline'
				theme="dark"
			>
				<Mitem k="1" name="首页" a="/"/>
				<Mitem k="2" name="服务器" a="/server/allserver"/>
				<Mitem k="3" name="其他" a="/server/test"/>

			</Menu>
		</>
	)
}