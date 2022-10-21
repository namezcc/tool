
function Test({data}) {
	return <div>
		getdata: {data}
	</div>
}

// export async function getServerSideProps(){
// 	const res = await fetch("http://localhost:8999/serverInfo")
// 	const data = await res.text()
// 	return {props:{
// 		data,
// 	}
// 	}
// }

export default Test