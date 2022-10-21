import {Layout,Table,Input,Button, Space,Collapse,message } from 'antd';
import styles from '../../styles/Home.module.css';
import { SearchOutlined } from '@ant-design/icons';
import MyPopConfirm from "../../component/popconfirm"
import { FETCH_HOST } from '../../component/const_data';

const { Content } = Layout;
const {Panel} = Collapse;
const { TextArea } = Input;

const getColumnSearchProps = dataIndex => ({
	filterDropdown: ({ setSelectedKeys, selectedKeys, confirm, clearFilters }) => (
	  <div style={{ padding: 8 }}>
		<Input
		  placeholder={`${dataIndex}`}
		  value={selectedKeys[0]}
		  onChange={e => setSelectedKeys(e.target.value ? [e.target.value] : [])}
		  style={{ marginBottom: 8, display: 'block' }}
		/>
		<Space>
		  <Button
			type="primary"
			onClick={() => confirm()}
			icon={<SearchOutlined />}
			size="small"
			style={{ width: 90 }}
		  >
			查找
		  </Button>
		  <Button
			type="link"
			size="small"
			onClick={() => {
				clearFilters();
			  	confirm();
			}}
		  >
			重置
		  </Button>
		</Space>
	  </div>
	),
	filterIcon: filtered => <SearchOutlined style={{ color: filtered ? '#1890ff' : undefined }} />,
	onFilter: (value, record) =>
	  record[dataIndex]
		? record[dataIndex].toString().toLowerCase().includes(value.toLowerCase())
		: '',
  });

const columns = [
	{
		title: "Name",
		dataIndex: "name",
		key:"name",
		filters:[
			{
				text:"login",
				value:"login",
			},
			{
				text:"game",
				value:"game",
			},
			{
				text:"close",
				value:"close",
			}
		],
		onFilter:(v,r)=> v==="close" ? r.open==0 : r.name === v,
	},
	{
		title: "Id",
		dataIndex: "id",
		key: "id",
	},
	{
		title: "Ip",
		dataIndex: "ip",
		key: "ip",
		...getColumnSearchProps("ip")
	},
	{
		title: "State",
		dataIndex: "error",
		key: "error",
	},
]

export async function getServerSideProps(){
	const res = await fetch(FETCH_HOST+"/serverInfo")
	const data = await res.json()
	return {props:{
		data,
	}
	}
}

var luatext = ""
var refserver = ""
var exceptser = ""

function desc_text() {
	var text = "热更范围:"
	if (refserver == "") {
		text += "全服,  "
	}else
		text += refserver+",   "

	return text+"排除的服:"+exceptser
}

function submit() {
	// console.log(refserver.split(",").map(v=>Number(v)))
	// console.log(exceptser.split(",").map(v=>Number(v)))
	// console.log(luatext)

	fetch(FETCH_HOST+"/hotload",{
		method:"POST",
		body:JSON.stringify({
			lua:luatext,
			server: refserver=="" ? [] : refserver.split(",").map(v=>Number(v)),
			except: exceptser=="" ? [] :exceptser.split(",").map(v=>Number(v)),
		})
	}).then(response=>{
		response.text().then(res=>message.info(res))
		//message.info(response.text())
	})
}

export default function AllServer({data=[]}) {
	return (
		<>
			<Layout className={styles.fullheight}>
				<Content>
					<Table
						rowKey={r=>r.type+'-'+r.id}
						columns={columns}
						dataSource={data}
						rowClassName={r=>r.open==0?styles.redtext:undefined}
					/>
					<Collapse>
						<Panel header="lua热更">
							<TextArea rows={10} onChange={e=>luatext=e.target.value }/><br/>
							<Input addonBefore="热更的服" placeholder='默认全服,“,”号分割' onChange={e=>refserver=e.target.value}/>
							<Input addonBefore="排除的服" placeholder='服务器id,“,”号分割' onChange={e=>exceptser=e.target.value}/>
							<MyPopConfirm
								title={"测试:"+luatext}
								onConfirm={submit}
								okText="确定"
								cancelText="取消"
								getdesc={desc_text}
							>
								<Button type='primary'>提交</Button>
							</MyPopConfirm>
						</Panel>
					</Collapse>
				</Content>
			</Layout>
		</>
	)
}