const audioelements = [];
const own_id = null;

for (let i = 0; i < 11; ++i)
{
	let sound = document.createElement('audio');
	sound.autoplay = true;
	sound.id = 'audioelement-'+i;
	audioelements.push(sound);
	document.body.appendChild(sound);
}

audioelements[10].autoplay=false;
audioelements[10].id='audioelement-test';

let localstream = null;
let peers = new Map();

class Peer
{
	constructor(webrtcConfig, id)
	{
		this.id = id;
		this.pc = new RTCPeerConnection(webrtcConfig);
		this.remotestream = new MediaStream();
		audioelements[this.id].srcObject=this.remotestream;
		this.speaking=false;
		this.offer=null;
		this.answer=null;
		this.candidates=[]
		if(localstream)
		{
			localstream.getAudioTracks().forEach(track=>{
				this.pc.addTrack(track, localstream);
			});
		};
		this.pc.ontrack = (event)=>{
			event.streams[0].getAudioTracks().forEach(track=>{
				this.remotestream.addTrack(track);
			});
		};
		this.pc.onicecandidate = (event) => {
			if(event.candidate) this.candidates.push(event.candidate.toJSON());
		};
	}
	setcandidate(candidate)
	{
		this.pc.addIceCandidate(new RTCIceCandidate(candidate));
	}
	call()
	{
		this.pc.createOffer().then((offer)=>{
			this.pc.setLocalDescription(offer);
			this.offer={sdp: offer.sdp, type: offer.type};
		})
	}
	setAnswer(answer)
	{
		this.pc.setRemoteDescription(new RTCSessionDescription(answer));
	}
	answercall(offer)
	{
		this.pc.setRemoteDescription(new RTCSessionDescription(offer)).then(()=>{
			this.pc.createAnswer().then((answerdescription)=>{
				this.pc.setLocalDescription(answerdescription);
				this.answer={sdp: answerdescription.sdp, type: answerdescription.type};
			});
		});
	}
	end()
	{
		this.pc.close();
	}
	setmute(mute)
	{
		this.remotestream.getAudioTracks().forEach(track=>{
			track.enabled=!mute;
		});
	}
}

function set_offer(offer, id)
{
	if(peers.has(id))
	{
		peers.get(id).answercall(offer);
	}
}

function set_answer(answer, id)
{
	if(peers.has(id))
	{
		peers.get(id).setAnswer(answer);
	}
}

function set_candidate(candidate, id)
{
	if(peers.has(id))
	{
		peers.get(id).setcandidate(candidate);
	}
}

function createpeer(webrtc, id)
{
	peers.set(id, new Peer(webrtc, id));
}

function callpeer(id)
{
	if(peers.has(id))
	{
		peers.get(id).call();
	}
}

function addpeer(id, webrtc)
{
	if(!peers.has(id))
	{
		peers.set(id, new Peer(webrtc, id));
	}
}

function removepeer(id)
{
	if(peers.has(id))
	{
		peers.get(id).end();
		peers.delete(id);
	}
}

function clearpeers()
{
	peers.forEach((peer)=>{
		peer.end();
	});
	peers.clear();
}

let gotstreaminfo = false

function poll()
{
	let ret = {};
	let peerinfo = {};
	peers.forEach((peer, id)=>{
		let p = {};
		if(peer.offer)
		{
			p.offer=peer.offer;
			peer.offer=null;
		}
		if(peer.answer){
			p.answer=peer.answer;
			peer.answer=null;
		}
		if(peer.candidates.length>0)
		{
			p.candidates=peer.candidates.slice();
			peer.candidates=[];
		}
		if(Object.keys(p).length>0) peerinfo[id]=p;
	});
	if(Object.keys(peerinfo).length>0) ret.peers=peerinfo;
	if(gotstreaminfo)
	{
		ret.gotstream=true;
		gotstreaminfo=false
	}
	return JSON.stringify(ret);
}

function askforstream()
{
	if(localstream==null) navigator.mediaDevices.getUserMedia({video: false, audio: true}).then(mediastream=>{
		if(localstream!=null) return;
		localstream=mediastream;
		audioelements[10].srcObject=localstream;
		setmute(true);
		peers.forEach(peer=>{
			localstream.getAudioTracks().forEach(track=>{
				peer.pc.addTrack(track, localstream);
			});
			peer.call();
		});
		gotstreaminfo=true;
	});
}


function soundtest(play)
{
	if(localstream===null)
	{
		askforstream();
		return;
	}
	if(play)
	{
		audioelements[10].play();
	}else
	{
		audioelements[10].pause();
	}
}

function isunmuted()
{
	let unmuted=false;
	if(localstream) for(let track of localstream.getAudioTracks())
	{
		if(track.enabled)
		{
			unmuted=true;
			break;
		}
	}
	return unmuted;
}

function setmute(m)
{
	if(localstream) localstream.getAudioTracks().forEach(track=>{
		track.enabled=!m;
	});
}

function setunmutepeers(m)
{
	peers.forEach((peer, id)=>{
		if(m&(1<<id))
		{
			peer.setmute(false);
		}else
		{
			peer.setmute(true);
		}
	});
}
