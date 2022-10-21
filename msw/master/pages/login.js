import {Layout,Input,Button,Space, Alert} from 'antd';
import { Content } from 'antd/lib/layout/layout';
import {getCsrfToken} from "next-auth/react"
import {useRouter} from "next/router";

function ErrAlert(p) {
	if (p.msg) {
		return (<Alert message={p.msg} type="error" />)
	}else{
		return (<></>)
	}
}

export default function SignIn(props) {
	const router = useRouter()
    var msg = router?.query?.msg
	if (msg) {
		msg = "用户名或密码错误"
	}
	return (
		<>
			<Layout>
				<Content>
					<form action='/api/auth/callback/credentials' method='POST'>
						<input name="csrfToken" type="hidden" defaultValue={props.csrfToken}/>
						<Space direction="vertical" style={{width: 300,marginLeft:100,marginTop:50 }}>
							<ErrAlert msg={msg} />
							<Input name='userName' addonBefore="user"/>
							<Input.Password name='password' addonBefore="password" />
							<Button type="primary" htmlType="submit" style={{marginLeft: '45%'}}>login</Button>
						</Space>
					</form>
				</Content>
			</Layout>
		</>
	)
}

//获取初始化csrfToken
export async function getServerSideProps(context) {
    return {
        props: {
            csrfToken: await getCsrfToken(context),
        },
    }
}