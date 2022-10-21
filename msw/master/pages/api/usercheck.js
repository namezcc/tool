import { FETCH_HOST } from '../../component/const_data';

export async function getUser(name,pass) {
	const res = await fetch(FETCH_HOST+"/userlogin",{
		method:"POST",
		body:JSON.stringify({
			name: name,
			pass: pass,
		})
	})

	const data = await res.text()
	if (data == "1") {
		return {username:name,res:1}
	}
	return {username:name,res:0}
}