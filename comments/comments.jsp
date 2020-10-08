<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>comments.jsp</title>
<style>
.comment {
	border: 1px dotted blue;
}
</style>
<script src='../js/jquery-3.5.1.min.js'></script>
<script>
	window.onload = function() {
		loadCommentsList();
	}
	//목록 조회
	function loadCommentsList() { //데이터를 읽어와서 디브아이디 코멘트리스트에 넣음
		$.ajax({
			url : '../CommentsServ', //서블릿 호출
			data : 'cmd=selectAll',
			//{cmd: 'selectAll'},  두 방식 다 됨 뒤에껀 오브젝트형식으로
			dataType : 'xml',
			type : 'get',
			success : loadCommentResult, //콜백함수
			error : function(a, b) {
				alert('댓글 로딩 실패: ' + b);
			}
		});
	}
	//콜백함수
	function loadCommentResult(xmlResult) {
		//console.log(xmlResult);
		let xmlDoc = xmlResult;
		let code = xmlDoc.getElementsByTagName('code').item(0).firstChild.nodeValue;
		if (code == 'success') {
			//data영역에 있는 코드를 읽어온다
			let commentList = eval('('
					+ xmlDoc.getElementsByTagName('data').item(0).firstChild.nodeValue
					+ ')');//'태그'
			//eval함수 들어있는 값을 평가하겠다
			console.log(commentList);
			let listDiv = $('#commentList');
			//for( field in commentList[0]) {
			//$(listDiv).append(commentList[0][field]); //sql에 있는 첫번째 인덱스값 가져옴

			//}
			for (let i = 0; i < commentList.length; i++) {
				let commentDiv = makeCommentView(commentList[i]);
				listDiv.append(commentDiv);
			}
		}
	}
	function makeCommentView(comment) {
		let div = document.createElement('div'); //$('<div />') 같음
		div.setAttribute('id', 'c' + comment.id);
		div.className = 'comment';
		div.comment = comment; //{id:2, name:홍길동,content:내용}

		let str = '<strong>' + comment.name + ' </strong>' + comment.content + //태그만들기
		' <input type="button" value="수정" onclick="viewUpdateForm('
				+ comment.id + ')">'
				+ ' <input type="button" value="삭제" onclick="confirmDeletion('
				+ comment.id + ')">';
		div.innerHTML = str;
		return div;
	}
	//등록 ajax호출
	function addComment() {
		let name = document.addForm.name.value;
		let content = document.addForm.content.value;
		if (name == null || name == "") {
			alert('name is invalid');
			return;
		} else if (content == null || content == "") {
			alert('content is invalid');
			return;
		}
		let params = 'name=' + name + '&content=' + content + '&cmd=insert';
		$.ajax({
			url : '../CommentsServ',
			dataType : 'xml', //xml파일로 받아올거다 성공이면 addResult
			data : params,
			success : addResult,
			error : function(a, b) {
				alert('서버 에러: ' + b);
			}
		});
	}
	//콜백함수
	function addResult(req) {

		let xmlDoc = req;
		let code = xmlDoc.getElementsByTagName('code').item(0).firstChild.nodeValue;
		if (code == 'success') {
			let comment = eval('('
					+ xmlDoc.getElementsByTagName('data').item(0).firstChild.nodeValue
					+ ')');
			let listDiv = document.getElementById('commentList');
			let commentDiv = makeCommentView(comment);
			listDiv.append(commentDiv);
			
			document.addForm.name.value = '';
			document.addForm.content.value = '';
			
			alert('등록했습니다!['+comment.id+']');
		}
	}
	//수정버튼 이벤트핸들러
	function viewUpdateForm(commentId) { //매개값으로 아이디가 들어있다
		let commentDiv = document.getElementById('c'+commentId);
		let updateFormDiv = document.getElementById('commentUpdate');
		commentDiv.after(updateFormDiv);
		
		let comment = commentDiv.comment; //{id:??,name:???,content:???}
		document.updateForm.id.value = comment.id;
		document.updateForm.name.value = comment.name;
		document.updateForm.content.value = comment.content;
		updateFormDiv.style.display = 'block';
		
		
	}
	
</script>
</head>
<body>
	<div id='commentList'></div>

	<!-- 글등록화면 -->
	<div id='commentAdd'>
		<form action="" name="addForm">
			이름:<input type="text" name="name" size="10"><br>
			내용:<textarea name="content" cols="20" row="2"></textarea>
			<br> <input type="button" value="등록" onclick="addComment()">
		</form>
	</div>
	<!-- 글 수정화면 -->
	<div id="commentUpdate" style="display: none;"> <!-- none은 안 보임 -->
	<form action="" name="updateForm">
	<input type="hidden" name="id" value="">
	이름: <input type="text" name="name" size="10"><br>
	내용: <textarea name="content" cols="20" rows="2"></textarea><br>
	<input type="button" value="변경" onclick="updateComment()">
	<input type="button" value="취소" onclick="cancelUpdate()">
 	</form>
	</div>
	
	
</body>
</html>