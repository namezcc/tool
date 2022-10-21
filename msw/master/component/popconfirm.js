import {Popconfirm} from "antd"
import React from 'react'

class MyPopConfirm extends React.Component {
	constructor(p){
		super(p)
		this.state = {
			desc:""
		}
	}

	render(){
		return (
			<Popconfirm
				title={"测试"+this.state.desc}
				onConfirm={this.props.onConfirm}
				okText={this.props.okText}
				cancelText={this.props.cancelText}
			>
				{React.Children.map(this.props.children,child=>{
					return React.cloneElement(child,{
						onClick:()=> this.setState({desc:this.props.getdesc()})
					})
				})}
			</Popconfirm>
		)
	}
}

export default MyPopConfirm