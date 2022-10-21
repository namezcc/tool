import '../styles/globals.css';
import "antd/dist/antd.css";
import MyLayout from '../component/layout';
import { SessionProvider } from "next-auth/react";

function MyApp({ Component, pageProps:{session,...pageProps} }) {
  return <SessionProvider session={session}>
	<MyLayout>
		<Component {...pageProps} />
	</MyLayout>
  </SessionProvider>
}

export default MyApp
