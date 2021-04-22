# DocViewer

특정 디렉토리 아래의 문서를 디렉토리(폴더)별로 구분해서 보여주는 프로그램입니다.
현재 html 포맷과 txt 파일을 지원합니다.

*디렉토리를 폴더 라고 부르겠습니다.*

## 시작하기
### 기본
문서를 지정된 폴더에 복사합니다.

지정 폴더는 다음과 같습니다.
* Windows 의 경우 내문서 아래의 docviewer
* Android 의 경우 Documents 아래의 docviewer

프로그램을 실행시키면 지정된 폴더의 바로 아래의 폴더와 그 폴더의 파일을 탐색하여 해당 정보를 가지는 _docviewer_info.json 파일을 만듭니다.

이 파일은 뷰어의 보여주는 프로그램의 Update - update file information 기능으로 업데이트 됩니다. 직접 json 편집기로 수정할 수 있습니다.

디렉토리 혹은 파일 이름이 _ 로 시작되면 탐색에서 제외됩니다

### 고급
#### 폴더별 아이콘 지정
_icon 폴더를 만들고 그 안에 폴더 이름과 동일한 이름의 png 파일을 넣으세요. 해당 폴더의 아이콘으로 사용됩니다.
#### _docviewer_info.json 설명

굵게 표시된 부분은 편집기를 사용해서 수정하여 사용할 수 있습니다.

* **lock 이 true 이면 Update 기능을 사용할 수 없게 합니다.**
* folders 아래
  * name 는 폴더의 실제 이름
  * **title 은 뷰어에서 보여줄 제목**
* files 아래
  * folder 는 파일이 있는 폴더 이름
  * name 은 실제 파일 이름
  * **title 은 뷰어에서 보여줄 제목**
  * **desc 는 뷰어에서 보여줄 파일에 대한 설명**
  * **datetime 은 뷰어에서 보여줄 날짜 (YYYY-MM-DD HH:MM 형식)**

## 지원 및 테스트 된 플랫폼
* [x] Windows
* [x] Android
* [ ] Mac
* [ ] iOS

## 앞으로 할 일
* Mac 및 iOS 지원
* 프로그램 설정 추가
 * 다크모드
 * 폰트변경
* Android 및 iOS에서 NativeWebView 사용
* 스토어 업로드

## 작성자
Alongthecloud - Kim

## 라이선스

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## 사용된 개발툴 및 라이브러리
* Flutter
  * **Libraries**
    - expandable_group_widget (include my source tree)
    - flutter_widget_from_html
    - path_provider
    - path
    - provider
    - sprintf
    * **For Android**
        - permission_handler
        - ext_storage
* Assets
    * 나눔고딕폰트 Copyright (c) 2010, NAVER Corporation (https://www.navercorp.com/)
