import vraklib
import net
import time

fn main() {
	l := net.listen_udp(19132) or { panic(err) }//binds to local address
	echo_server(l)
}

fn echo_server(_c net.UdpConn) {
	mut c := _c
	for {
		mut buf := []byte{len: 1500, init: 0}
		n, addr := c.read(mut buf) or { continue }//addr is from recvfrom, client address
		if n <= 0{
			continue//no data, receive next
		}
		println('Got address $addr')
		println('Got $n vs $buf.len bytes: "$buf.bytestr()"')
		// trim data
		buf = buf[..n]
		println('Got $n bytes: "$buf.bytestr()"')
		mut b := vraklib.new_bytebuffer(buf, u32(n))
		pid := b.get_byte()
		println(pid)
		mut ping := vraklib.UnConnectedPing{}
		println(ping)
		ping.decode(mut b)
		println(ping)
		println(b.buffer.bytestr())
		title := 'MCPE;PocketMine-MP Server;422;1.16.200;0;20;6110147563508788599;PocketMine-MP;Creative;'
		len := 35 + title.len
		buf = []byte{len: len, init: 0}
		mut pong := vraklib.UnConnectedPong{
			p: vraklib.new_packet(buf, u32(len))
			server_guid: 6110147563508788599
			send_timestamp: ping.send_timestamp
			// send_timestamp: timestamp()
			data: title.bytes()
		}
		// packet.buffer.reset()
		pong.encode(mut pong.p.buffer)
		buf = pong.p.buffer.buffer
		println(buf)

		println('Writing to address $addr: $buf')
		mut error := c.write_to(addr, buf) or { panic(err) }//sends thedata to the client C.sendto, returns int on error, none otherwise
		println(error)
		if error == buf.len{
		println('Success')
		}else{
		println('Failed')}
	}
	c.close() or {
		 	println('Server: connection dropped')
		 	panic(err)
	}
}

// timestamp returns a timestamp in milliseconds.
fn timestamp() u64 {
	return time.now().unix_time_milli()
}
