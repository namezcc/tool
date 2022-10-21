import MySider from './sider';
import {Layout} from 'antd';
import styles from '../styles/Home.module.css';

const { Sider ,Header,Content } = Layout;

export default function MyLayout({children}) {
	return (
		<>
			<Layout className={styles.main}>
				<Sider>
					<MySider/>
				</Sider>
				<Layout >
					<Header></Header>
					<Content>{children}</Content>
				</Layout>
			</Layout>
		</>
	)
}