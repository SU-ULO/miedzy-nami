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
		this.offer=null;
		this.answer=null;
		this.candidates=[]
		if(localstream)
		{
			localstream.getAudioTracks().forEach((track)=>{
				this.pc.addTrack(track, localstream);
			});
		};
		this.pc.ontrack = (event)=>{
			event.streams[0].getAudioTracks().forEach((track)=>{
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

function poll()
{
	let ret = {};
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
		if(Object.keys(p).length>0) ret[id]=p;
	});
	if(Object.keys(ret).length>0) return JSON.stringify(ret);
	else return null;
}

function askforstream()
{
	navigator.mediaDevices.getUserMedia({video: false, audio: true}).then((mediastream)=>{
		localstream=mediastream;
		audioelements[10].srcObject=localstream;
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
