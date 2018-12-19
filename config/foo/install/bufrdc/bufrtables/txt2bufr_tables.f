      PROGRAM TXT2BUFR_TABLES
C Copyright 1981-2012 ECMWF.
C
C This software is licensed under the terms of the Apache Licence 
C Version 2.0 which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
C
C In applying this licence, ECMWF does not waive the privileges and immunities 
C granted to it by virtue of its status as an intergovernmental organisation 
C nor does it submit to any jurisdiction.
C
C
C**** *TXT2BUFR_TABLES*
C
C
C     PURPOSE.
C     --------
C          CREATES BYNARY BUFR TABLES USED BY BUFR EXPANSION
C          OR BUFR ENCODING SOFTWARE
C
C**   INTERFACE.
C     ----------
C          NONE.
C
C
C     *METHOD.
C      -------
C          NONE.
C
C
C     EXTERNALS.
C     ----------
C          NONE.
C
C
C
C
C     REFERENCE.
C     ----------
C
C          BINARY UNIVERSAL FORM FOR DATA REPRESENTATION, FM 94 BUFR.
C
C          J.K.GIBSON AND M.DRAGOSAVAC,1987: DECODING DATA 
C          REPRESENTATION FM 94 BUFR,TECHNICAL MEMORANDUM NO.
C
C          J.K.GIBSON,1986:EMOS 2 - STANDARDS FOR SOFTWARE DEVELOPMENT
C          AND MAINTANANCE ,TECHICAL MEMORANDUM NO.       ECMWF.
C
C
C     AUTHOR.
C     -------
C
C          M. DRAGOSAVAC       *ECMWF*       JANUARY 1991.
C
C
C     MODIFICATIONS.
C     --------------
C
C          NONE.
C
C
      IMPLICIT LOGICAL(L,O,G), CHARACTER*8(C,H,Y)
C
      character*256 carg(2),cf
c
C
C     ------------------------------------------------------------------
C*          1.   CREATE BINARY BUFR TABLES.
C                __________________________
 100  CONTINUE
C
      ierr=0
C     Input file name
C
C     Get input and output file name.
C
      narg=IARGC()
c
      IF(narg.NE.2) THEN
         print*,'Usage -- txt2bufr_tables -i infile '
         stop
      END IF
c
      do 101 j=1,narg
      call getarg(j,carg(j))
 101  continue
c
      if(carg(1).ne.'-i'.and.carg(1).ne.'-I'.or.
     1   carg(2).eq.' ') then
         print*,'Usage -- txt2bufr_tables -i inpfile '
         stop
      end if
c
      cf=carg(2)
      ii=index(cf,' ')
      ii=ii-1
c
C*          2. TABLE B.
C              --------
 200  CONTINUE
C
      IF(cf(1:1).eq.'B') THEN
         CALL BTABLE(cf,IERR)
         IF(IERR.NE.0) THEN
            WRITE(*,'(1H ,A,A,A)') 'Warning --- Bufr Table ',ybtable,
     1                             ' not created.'
            IERR=0
         END IF
C
C*          3. TABLE C.
C              --------
 300  CONTINUE
C
      ELSEIF(cf(1:1).eq.'C') THEN
         CALL CTABLE(cf,IERR)
         IF(IERR.NE.0) THEN
            WRITE(*,'(1H ,A,A,A)') 'Warning --- Bufr Table ',yctable,
     1                             ' not created'
            IERR=0
         END IF
C
C*          4. TABLE D.
C              --------
 400  CONTINUE
C
      ELSEIF(cf(1:1).eq.'D') THEN
         CALL DTABLE(cf,IERR)
         IF(IERR.NE.0) THEN
            WRITE(*,'(1H ,A,A,A)') 'Warning --- Bufr Table ',ydtable,
     1                             ' not created'
            IERR=0
         END IF
      ELSE
         PRINT*,'Error - This is not B,C or D bufr Table!'
      ENDIF
C
      END
      SUBROUTINE BTABLE(YNAME,KERR)
C
C**** *BTABLE*
C
C
C     PURPOSE.
C     --------
C          CREATE BUFR TABLE B IN BINARY FORM.
C
C**   INTERFACE.
C     ----------
C          NONE.
C
C
C     *METHOD.
C      -------
C          NONE.
C
C
C     EXTERNALS.
C     ----------
C          NONE.
C
C
C
C
C     REFERENCE.
C     ----------
C
C          BINARY UNIVERSAL FORM FOR DATA REPRESENTATION, FM 94 BUFR.
C
C          J.K.GIBSON AND M.DRAGOSAVAC,1987: DECODING DATA 
C          REPRESENTATION FM 94 BUFR,TECHNICAL MEMORANDUM NO.
C
C          J.K.GIBSON,1986:EMOS 2 - STANDARDS FOR SOFTWARE DEVELOPMENT
C          AND MAINTANANCE ,TECHICAL MEMORANDUM NO.       ECMWF.
C
C
C     AUTHOR.
C     -------
C
C          M. DRAGOSAVAC       *ECMWF*       JANUARY 1991.
C
C
C     MODIFICATIONS.
C     --------------
C
C          NONE.
C
C
      IMPLICIT LOGICAL(O,G), CHARACTER*8(C,H)
C
      PARAMETER(JSUP = 9,JSEC0=   3,JSEC1= 40,JSEC2=4096 ,JSEC3=    4,
     1          JSEC4=2,JELEM=160000,JSUBS=400,JCVAL=150 ,JBUFL=512000,
     2          JBPW = 32,JTAB =3000,JCTAB=3000,JCTST=3000,JCTEXT=6000,
     3          JWORK=4096000,JKEY=46)
C
      PARAMETER (KELEM=80000)
      PARAMETER (KVALS=360000)
C
      DIMENSION KBUFF(JBUFL)
      DIMENSION KSUP(JSUP)  ,KSEC0(JSEC0),KSEC1(JSEC1)
      DIMENSION KSEC2(JSEC2),KSEC3(JSEC3),KSEC4(JSEC4)
C
      REAL*8 VALUES(KVALS)
      DIMENSION KTDLST(KELEM)
      DIMENSION KDATA(10)
C

      CHARACTER*80 CVALS(KVALS)
C
      CHARACTER*120 YENTRY,YENTRY1
C
      CHARACTER*(*) YNAME
      CHARACTER*120  YFNAME
c
C
C
C     ------------------------------------------------------------------
C*          1.   INITIALIZE CONSTANTS AND VARIABLES.
C                -----------------------------------
 100  CONTINUE
C
      kbufl=jbufl
      i=index(yname,' ')
      i=i-1
      if(i.eq.14) then
C
C        Bufr Edition 0,1,2
C
         read(yname(9:10),'(i2)') ilocal
         read(yname(7:8),'(i2)') imaster
         iedition=2
         yfname=yname(1:10)//'.buf'
      elseif(i.eq.15) then
C
C        Bufr Edition 3
C
         read(yname(10:11),'(i2)') ilocal
         read(yname(8:9),'(i2)') imaster
         read(yname(2:4),'(i2)') isubcentre
         read(yname(5:7),'(i2)') icentre
         iedition=3
         yfname=yname(1:11)//'.buf'
      elseif(i.eq.24) then
C
C        Bufr Edition 4
C
         read(yname(18:20),'(i3)') ilocal
         read(yname(15:17),'(i3)') imaster
         read(yname(5:9),'(i5)') isubcentre
         read(yname(10:14),'(i5)') icentre
         iedition=4
         yfname=' '
         yfname=yname(1:20)//'.buf'
      else
         print*,'Wrong Bufr table name --',cf
         call exit(2)
      end if

      J=0
      jj=0
C
C
      call pbopen(IUNIT1,yfname,'w',IRET)
      IF(IRET.EQ.-1) STOP 'open failed on bufr.dat'
      IF(IRET.EQ.-2) STOP 'Invalid file name'
      IF(IRET.EQ.-3) STOP 'Invalid open mode specified'

      OPEN(UNIT=21,FILE=YNAME(1:i),
     1            ERR=401,
     2            IOSTAT=IOS,      
     3            STATUS='OLD')
c
c     000001
      jj=jj+1
      cvals(jj)='011'
      values(jj)=jj*1000+3
c
c     000002
      jj=jj+1
      cvals(jj)='BUFR TABLES, COMPLETE'
      values(jj)=jj*1000+32
c
c     000003
      jj=jj+1
      cvals(jj)=' '
      values(jj)=jj*1000+32

c
c     000004 BUFR master table
      jj=jj+1
      cvals(jj)='00'
      values(jj)=jj*1000+2
c
c     000005 BUFR edition number
c
      jj=jj+1
      cvals(jj)='004'
      values(jj)=jj*1000+3
c
c     000006 BUFR master table version number
      jj=jj+1
      print*,'imaster=',imaster
      write(cvals(jj)(1:2),'(I2.2)') imaster
      values(jj)=jj*1000+2
c
c     000008 BUFR local table version number
      jj=jj+1
      print*,'ilocal=',ilocal
      write(cvals(jj)(1:2),'(I2.2)') ilocal
      values(jj)=jj*1000+2


c     Replication factor
      jj=jj+1
      values(jj)=0
c
C     ------------------------------------------------------------------
C*          2.   READ IN TABLE B ELEMENT.
C                ------------------------
C
      iii=0
 200  CONTINUE
C
      YENTRY=' '
      READ(21,'(A)',ERR=402,END=300) YENTRY
      iii=iii+1
C
C
C*          2.1  SET ARRAYS FOR TABLE REFERENCE, ELEMENT NAME, UNITS,
C*               REFERENCE VALUE AND DATA WIDTH.
C
 210  CONTINUE
C
c
c     F
c
      jj=jj+1
      cvals (jj)=yentry(2:2)
      values(jj)=jj*1000+1
c
c     X
c
      jj=jj+1
      cvals (jj)=yentry(3:4)
      values(jj)=jj*1000+2
c
c     Y
c
      jj=jj+1
      cvals (jj)=yentry(5:7)
      values(jj)=jj*1000+3
c
c     Namne 1
c
      jj=jj+1
      cvals (jj)=yentry(9:40)
      values(jj)=jj*1000+32
c
c     Name 2
c
      jj=jj+1
      cvals (jj)=yentry(41:72)
      values(jj)=jj*1000+32
c
c     Unit name
c
      jj=jj+1
      cvals (jj)=yentry(74:97)
      values(jj)=jj*1000+24
c
c     Unit scale sign
c
      iz=0
      jj=jj+1
      iz=index(yentry(98:101),'-')
      if(iz.eq.0) then
         cvals (jj)='+'
         values(jj)=jj*1000+1
      else
         cvals (jj)='-'
         values(jj)=jj*1000+1
      end if
c
c     Unit scale
c
      jj=jj+1
      if(iz.ne.0) then
         izz=98+iz-1
         yentry(izz:izz)=' '
         cvals (jj)=yentry(99:101)
         values(jj)=jj*1000+3
      else
        cvals (jj)=yentry(99:101)
        values(jj)=jj*1000+3
      end if
c
c     Unit reference sign
c
      iz=0
      jj=jj+1
      iz=index(yentry(102:114),'-')
      if(iz.eq.0) then
         cvals (jj)='+'
         values(jj)=jj*1000+1
      else
         cvals (jj)='-'
         values(jj)=jj*1000+1
      end if
c
c     Unit reference      
c
      jj=jj+1
      if(iz.ne.0) then
         izz=102+iz-1
         yentry(izz:izz)=' '
         cvals (jj)=yentry(105:114)
         values(jj)=jj*1000+10
      else
         cvals (jj)=yentry(105:114)
         values(jj)=jj*1000+10
      end if
c
c     Element data width
c
      jj=jj+1
      cvals (jj)=yentry(116:118)
      values(jj)=jj*1000+3
c
c     end of element descriptors
c
      GO TO 200
C
C     ------------------------------------------------------------------
C*          3.   Pack tables into bufr message
C                --------------------------------
 300  CONTINUE
C
c     Set section 0
c
      ksec0(3)=iedition
c
c     Set section 1
c
      IF(KSEC0(3).LE.3) THEN
        ksec1(1)=18
        ksec1(2)=iedition
        ksec1(3)=icentre
        ksec1(4)=1
        ksec1(5)=0
        ksec1(6)=11
        ksec1(7)=1
        ksec1(8)=ilocal
        ksec1(9)=4
        ksec1(10)=6
        ksec1(11)=21
        ksec1(12)=0
        ksec1(13)=0
        ksec1(14)=0
        ksec1(15)=imaster
        ksec1(16)=isubcentre
      ELSE
        ksec1(1)=22
        ksec1(2)=iedition
        ksec1(3)=icentre
        ksec1(4)=1
        ksec1(5)=0
        ksec1(6)=11
        ksec1(7)=0
        ksec1(8)=ilocal
        ksec1(9)=2007
        ksec1(10)=2
        ksec1(11)=7
        ksec1(12)=0
        ksec1(13)=0
        ksec1(14)=0
        ksec1(15)=imaster
        ksec1(16)=isubcentre
        ksec1(17)=1
        ksec1(18)=0
      END IF
c
c     Set section 3
c
      ksec3(3)=1
      ksec3(4)=128
c
c     Set replication factor
c
      print*,'delayed replication is ',iii
      kdata(1)=iii
      kdlen=1
      values(8)=iii
c
c     Set list of descriptors
c
      ktdlst( 1)=  000001
      ktdlst( 2)=  000002
      ktdlst( 3)=  000003
      ktdlst( 4)=  000004
      ktdlst( 5)=  000005
      ktdlst( 6)=  000006
      ktdlst( 7)=  000008
      ktdlst( 8)=  101000
      ktdlst( 9)=  031002
      ktdlst(10)=  300004
c
      ktdlen=10
c
      call bufren(ksec0,ksec1,ksec2,ksec3,ksec4,ktdlen,ktdlst,
     1            kdlen,kdata,kelem,kvals,values,cvals,
     2            kbufl,kbuff,ierr)
c
      if(ierr.ne.0) then
         print*,'bufren: error ',ierr
         call exit(2)
      end if
c
      print*,'Number of table B entries packed =',iii
c
      ilen=kbufl*4
      print*,'total length of bufr message is ',ilen
      call pbwrite(IUNIT1,KBUFF,ILEN,IERR)
      return
C     -----------------------------------------------------------------
 400  CONTINUE
C
      RETURN
C
404   CONTINUE
      KERR=1
      WRITE(*,4404) IOS,yname
 4404 FORMAT(1H ,'Write error',i4,' on ',a)
      RETURN
C
403   CONTINUE
      KERR=1
      WRITE(*,4403) IOS,yname
4403  FORMAT(1H ,'Open error',i4,' on ',a)
      RETURN
C
C
402   CONTINUE
      KERR=1
      WRITE(*,4402) IOS,yfname
 4402 FORMAT(1H ,'Read error',i4,' on ',a)
      RETURN
C
C
 401  CONTINUE
C
      KERR=1
      WRITE(*,4401) IOS,yfname
 4401 FORMAT(1H ,'Open error',i4,' on ',a)
C     
      RETURN
      END
      SUBROUTINE DTABLE(YNAME,KERR)
C
C**** *DTABLE*
C
C
C     PURPOSE.
C     --------
C          THE MAIN PURPOSE OF THIS PROGRAMME IS TO CREATE WORKING
C          TABLE OF SEQUENCE DESCRIPTORS FOR *BUFR* DECODING.
C
C**   INTERFACE.
C     ----------
C          NONE.
C
C
C
C
C     *METHOD.
C      -------
C          NONE.
C
C
C
C     EXTERNALS.
C     ----------
C          NONE.
C
C
C
C
C     REFERENCE.
C     ----------
C
C          BINARY UNIVERSAL FORM FOR DATA REPRESENTATION, *FM 94 BUFR*.
C
C          J.K.GIBSON AND *M.DRAGOSAVAC,1987:* DECODING *DATA *REPRESENTATION
C                          *FM 94 BUFR*,*TECHNICAL *MEMORANDUM *NO.
C
C          J.K.GIBSON,1986:*EMOS 2 - *STANDARDS FOR SOFTWARE DEVELOPMENT
C                           AND MAINTANANCE *,*TECHICAL MEMORANDUM *NO.
C                           *ECMWF*.
C
C
C     AUTHOR.
C     -------
C
C          M. DRAGOSAVAC       *ECMWF*       JANUARY 1991.
C
C
C     MODIFICATIONS.
C     --------------
C
C          NONE.
C
C
      IMPLICIT LOGICAL(O,G), CHARACTER*8(C,H)
C
      PARAMETER(JSUP = 9,JSEC0=   3,JSEC1= 40,JSEC2=4096 ,JSEC3=    4,
     1          JSEC4=2,JELEM=160000,JSUBS=400,JCVAL=150 ,JBUFL=512000,
     2          JBPW = 32,JTAB =3000,JCTAB=3000,JCTST=3000,JCTEXT=6000,
     3          JWORK=4096000,JKEY=46)
C
      PARAMETER (KELEM=20000)
      PARAMETER (KVALS=360000)
C
      DIMENSION KBUFF(JBUFL)
      DIMENSION KSUP(JSUP)  ,KSEC0(JSEC0),KSEC1(JSEC1)
      DIMENSION KSEC2(JSEC2),KSEC3(JSEC3),KSEC4(JSEC4)
C
      REAL*8 VALUES(KVALS)
      DIMENSION KTDLST(KELEM)
      DIMENSION KDATA(1000)
C
      CHARACTER*80 CVALS(KVALS)
C
      character*80 YENTRY
C
      CHARACTER*(*) YNAME
      CHARACTER*256 YFNAME
C     ------------------------------------------------------------------
C*          1.   INITIALIZE CONSTANTS AND VARIABLES.
C                -----------------------------------
 100  CONTINUE
C
      kbufl=jbufl
      i=index(yname,' ')
      i=i-1
      if(i.eq.14) then
c
c        Bufr Edition 0,1,2
c
         read(yname(9:10),'(i2)') ilocal
         read(yname(7:8),'(i2)') imaster
         iedition=2
         yfname=' '
         yfname=yname(1:10)//'.buf'
      elseif(i.eq.15) then
c
c        Bufr Editin 3
c
         read(yname(10:11),'(i2)') ilocal
         read(yname(8:9),'(i2)') imaster
         iedition=3
         yfname=' '
         yfname=yname(1:11)//'.buf'
      elseif(i.eq.24) then
c     
c        Bufr Editin 4
c
         read(yname(18:20),'(i3)') ilocal
         read(yname(15:17),'(i3)') imaster
         read(yname(5:9),'(i5)') isubcentre
         read(yname(10:14),'(i5)') icentre

         iedition=4
         yfname=' '
         yfname=yname(1:20)//'.buf'


      else
         print*,'Wrong table name ---',yname
         call exit(2)
      end if
c
      J=1
      jj=0
C
      call pbopen(IUNIT1,yfname,'w',IRET)
      IF(IRET.EQ.-1) STOP 'open failed on bufr.dat'
      IF(IRET.EQ.-2) STOP 'Invalid file name'
      IF(IRET.EQ.-3) STOP 'Invalid open mode specified'

      OPEN(UNIT=21,FILE=YNAME(1:i),
     1            ERR=401,
     2            IOSTAT=IOS,
     3            STATUS='OLD')
c
      jj=jj+1
      cvals(jj)='011'
      values(jj)=jj*1000+3
C     000002
      jj=jj+1
      cvals(jj)='BUFR TABLES, COMPLETE'
      values(jj)=jj*1000+32
c
c     000003
      jj=jj+1
      cvals(jj)=' '
      values(jj)=jj*1000+32

c
c     000004 BUFR master table
      jj=jj+1
      cvals(jj)='00'
      values(jj)=jj*1000+2
c
c     000005 BUFR edition number
c
      jj=jj+1
      cvals(jj)='004'
      values(jj)=jj*1000+3
c
c     000006 BUFR master table version number
      jj=jj+1
      print*,'imaster=',imaster
      write(cvals(jj)(1:2),'(I2.2)') imaster
      values(jj)=jj*1000+2
c
c     000008 BUFR local table version number
      jj=jj+1
      print*,'ilocal=',ilocal
      write(cvals(jj)(1:2),'(I2.2)') ilocal
      values(jj)=jj*1000+2

c     Replication factor for all table D entries
c
      jj=jj+1
      values(jj)=0
C
C     ------------------------------------------------------------------
C*          2.   READ IN TABLE D ELEMENT.
C                ------------------------
C
 200  CONTINUE
C
      YENTRY=' '
      READ(21,'(A)',ERR=402,END=300) YENTRY
      j=j+1
C
C
C*          2.1  SET ARRAYS FOR TABLE REFERENCE, ELEMENT NAME, UNITS,
C*               REFERENCE VALUE AND DATA WIDTH.
C
 210  CONTINUE
C
c
c     F
c
      jj=jj+1
      cvals (jj)=yentry(2:2)
      values(jj)=jj*1000+1
c
c     X
c
      jj=jj+1
      cvals (jj)=yentry(3:4)
      values(jj)=jj*1000+2
c
c     Y
c
      jj=jj+1
      cvals (jj)=yentry(5:7)
      values(jj)=jj*1000+3
c
c     Replication factor
c
      jj=jj+1
      read(yentry(9:10),'(i2)') irepl
      values(jj)=float(irepl)
      kdata(j)=irepl
c
c     Sequence descriptors
c   
      jj=jj+1
      cvals(jj)=yentry(12:17)
      values(jj)=jj*1000+6
c
      do 220 i=1,irepl-1
      READ(21,'(A)',ERR=402,END=300) YENTRY
c
      jj=jj+1
      cvals(jj)=yentry(12:17)
      values(jj)=jj*1000+6
220   continue
c
      GO TO 200
C
C     ------------------------------------------------------------------
C*          3.   Pack tables into bufr message
C                --------------------------------
 300  CONTINUE
C
c     Set section 0
c
      ksec0(3)=iedition
c
c     Set section 1
c
      IF(KSEC0(3).LE.3) THEN
        ksec1(1)=18
        ksec1(2)=iedition
        ksec1(3)=98
        ksec1(4)=1
        ksec1(5)=0
        ksec1(6)=11
        ksec1(7)=2
        ksec1(8)=ilocal
        ksec1(9)=95
        ksec1(10)=9
        ksec1(11)=17
        ksec1(12)=12
        ksec1(13)=0
        ksec1(14)=0
        ksec1(15)=imaster
        ksec1(16)=0
      ELSE
        ksec1(1)=22
        ksec1(2)=iedition
        ksec1(3)=icentre
        ksec1(4)=1
        ksec1(5)=0
        ksec1(6)=11
        ksec1(7)=0
        ksec1(8)=ilocal
        ksec1(9)=2005
        ksec1(10)=6
        ksec1(11)=7
        ksec1(12)=0
        ksec1(13)=0
        ksec1(14)=0
        ksec1(15)=imaster
        ksec1(16)=isubcentre
        ksec1(17)=2
        ksec1(18)=0
      END IF
c
c     Set section 3
c
      ksec3(3)=1
      ksec3(4)=128
c
c     Set replication factor
c
      print*,'delayed replication is ',j
      kdata(1)=j-1
      kdlen=j
      values(8)=j-1
c
c     Set list of descriptors
c
      ktdlst(1)=000001
      ktdlst(2)=000002
      ktdlst(3)=000003
      ktdlst(4)=000004
      ktdlst(5)=000005
      ktdlst(6)=000006
      ktdlst(7)=000008
      ktdlst(8)=104000
      ktdlst(9)=031002
      ktdlst(10)=300003
      ktdlst(11)=101000
      ktdlst(12)=031002
      ktdlst(13)=000030
c
      ktdlen=13
c
      call bufren(ksec0,ksec1,ksec2,ksec3,ksec4,ktdlen,ktdlst,
     1            kdlen,kdata,kelem,kvals,values,cvals,
     2            kbufl,kbuff,ierr)
c
      if(ierr.gt.0) then
         print*,'bufren: error ',ierr
         call exit(2)
      end if
c
      print*,'Number of table D entries packed =',j
c
      ilen=kbufl*JBPW/8
      print*,'total length of bufr message is ',ilen
      call pbwrite(IUNIT1,KBUFF,ILEN,IERR)
      return
C     -----------------------------------------------------------------
 400  CONTINUE
C
      RETURN
C
404   CONTINUE
      KERR=1
      WRITE(*,4404) IOS,yname
 4404 FORMAT(1H ,'Write error',i4,' on ',a)
      RETURN
C
403   CONTINUE
      KERR=1
      WRITE(*,4403) IOS,yname
4403  FORMAT(1H ,'Open error',i4,' on ',a)
      RETURN
C
C
402   CONTINUE
      KERR=1
      WRITE(*,4402) IOS,yfname
 4402 FORMAT(1H ,'Read error',i4,' on ',a)
      RETURN
C
C
 401  CONTINUE
C
      KERR=1
      WRITE(*,4401) IOS,yfname
 4401 FORMAT(1H ,'Open error',i4,' on ',a)
C
      RETURN
      END
      SUBROUTINE CTABLE(YNAME,KERR)
C
C**** *CTABLE*
C
C
C     PURPOSE.
C     --------
C          THE MAIN PURPOSE OF THIS PROGRAMME IS TO CREATE WORKING
C          CODE TABLES FOR *BUFR* DECODING.
C
C**   INTERFACE.
C     ----------
C          NONE.
C
C
C
C
C     *METHOD.
C      -------
C          NONE.
C
C
C
C     EXTERNALS.
C     ----------
C          NONE.
C
C
C
C
C     REFERENCE.
C     ----------
C
C          BINARY UNIVERSAL FORM FOR DATA REPRESENTATION, *FM 94 BUFR*.
C
C          J.K.GIBSON AND *M.DRAGOSAVAC,1987:* DECODING *DATA *REPRESENTATION
C                          *FM 94 BUFR*,*TECHNICAL *MEMORANDUM *NO. 134
C
C          J.K.GIBSON,1986:*EMOS 2 - *STANDARDS FOR SOFTWARE DEVELOPMENT
C                           AND MAINTANANCE *,*TECHICAL MEMORANDUM *NO.
C                           *ECMWF*.
C
C
C     AUTHOR.
C     -------
C
C          M. DRAGOSAVAC       *ECMWF*       JANUARY 1991.
C
C
C     MODIFICATIONS.
C     --------------
C
C          NONE.
C
C
      IMPLICIT LOGICAL(L,O,G), CHARACTER*8(C,H,Y)
C
      PARAMETER(JSUP = 9,JSEC0=   3,JSEC1= 40,JSEC2=4096 ,JSEC3=    4,
     1          JSEC4=2,JELEM=160000,JSUBS=400,JCVAL=150 ,JBUFL=512000,
     2          JBPW = 32,JTAB =3000,JCTAB=3000,JCTST=3000,JCTEXT=6000,
     3          JWORK=4096000,JKEY=46)

C
      CHARACTER*64 CTEXT(JCTEXT)
      CHARACTER*80 YENTRY
      CHARACTER*120 YFNAME
      CHARACTER*(*) YNAME
C
      DIMENSION NREF(JCTAB),NSTART(JCTAB),NLEN(JCTAB),NCODNUM(JCTST),
     1          NSTARTC(JCTST),NLENC(JCTST)
C
C     ------------------------------------------------------------------
C*          1.   SET INITIAL CONSTANTS AND POINTERS
C                ----------------------------------
 100  CONTINUE
C
      J=0
      iynamep=index(yname,' ')
      iynamep=iynamep-1
      
c
      if(iynamep.eq.14) then
c
c        Bufr Edition 0,1,2
c
         read(yname(9:10),'(i2)') ilocal
         read(yname(7:8),'(i2)') imaster
         iedition=2
         yfname=yname(1:10)//'.buf'
      elseif(iynamep.eq.15) then
c
c        Bufr Editin 3
c
         read(yname(10:11),'(i2)') ilocal
         read(yname(8:9),'(i2)') imaster
         iedition=3
         yfname=yname(1:11)//'.buf'
      elseif(iynamep.eq.24) then
c
c        Bufr Editin 4
c
         read(yname(18:20),'(i3)') ilocal
         read(yname(15:17),'(i3)') imaster
         read(yname(5:9),'(i5)') isubcentre
         read(yname(10:14),'(i5)') icentre
         iedition=4
         yfname=' '
         yfname=yname(1:20)//'.buf'
      else
         print*,'Wrong table name ---',yname
         call exit(2)
      end if
c
c
      JPN4=JP*JPN*4
C
      DO 101 I=1,JPN4
      CTEXT(I)=' '
 101  CONTINUE
C
      DO 102 I=1,JP
      NREF(I)=0
      NSTART(I)=0
      NLEN(I)=0
 102  CONTINUE
C
      DO 103 I=1,JP*JPN
      NCODNUM(I)=0
      NSTARTC(I)=0
      NLENC  (I)=0
 103  CONTINUE
C
      OPEN(UNIT=21,FILE=YNAME(1:iynamep),ERR=401,STATUS='OLD')
C
C     ------------------------------------------------------------------
C*          2.   READ IN CODE TABLE ENTRY
C                ------------------------
 200  CONTINUE
C
C
      READ(21,'(A)',ERR=402,END=300) YENTRY
      print*,YENTRY
C
      J = J+1
C
      IF(J.GT.JP) THEN
         PRINT*,' DIMENSION TOO SMALL J=',J
         CALL EXIT(2)
      END IF 
C
C     ------------------------------------------------------------------
C*          2.1  SET ARRAYS FOR CODE TABLE TABLE REFERENCE, STARTING POINTERS
C                FOR LIST OF CODE NUMBERS, LENGTH , LIST OF CODE NUMBERS,
C                STARTING POINTERS AND LENGTH OF TEXT INFORMATION.
 210  CONTINUE
C
      READ(YENTRY,'(I6,1X,I4,1X,I4,1X,I2)') NREF(J),NLEN(J),NCODE,NLINE
C
      IF(J.EQ.1) THEN
         NSTART (J)  = 1
         NSTARTC(J)  = 1
         IPT = 1
         IIPT= 1
      ELSE
         NSTART(J)   = NSTART(J-1) + NLEN(J-1)
         IPT         = NSTART(J)
         IIPT        = IIPT + 1
         NSTARTC(IPT)= IIPT
      END IF
C
C
      NCODNUM(IPT)=NCODE
      NLENC ( IPT)=NLINE
C
      CTEXT (IIPT)=YENTRY(21:80)
C     -------------------------------------------------------------------
      IF(NLENC(IPT).GT.1) THEN
         DO 220 JA=1,NLENC(IPT)-1
         READ(21,'(A)',END=300) YENTRY
         IIPT=IIPT+1
         CTEXT(IIPT)=YENTRY(21:80)
 220     CONTINUE
      END IF
C
      IF(NLEN(J).GT.1) THEN
         DO 230 JA=1,NLEN(J)-1
         READ(21,'(A)',END=300) YENTRY
         print*,YENTRY
         READ(YENTRY,'(12X,I4,1X,I2)') NCODE,NLINE
         IPT   = IPT + 1
         IIPT  =IIPT + 1
         NCODNUM(IPT)= NCODE
         NSTARTC(IPT)=  IIPT
         NLENC  (IPT)=NLINE
         CTEXT(IIPT) = YENTRY(21:80)
         IF(NLENC(IPT).GT.1) THEN
            DO 240 JB=1,NLENC(IPT)-1
            READ(21,'(A)',END=300) YENTRY
            IIPT=IIPT+1
            CTEXT(IIPT)=YENTRY(21:80)
 240        CONTINUE
         END IF
 230     CONTINUE
      END IF
C
      GO TO 200
C
C     ------------------------------------------------------------------
C*          3.   WRITE WORKING CODE TABLE INTO FILE.
C                -----------------------------------
 300  CONTINUE
C
      i=index(yfname,' ')
      OPEN(UNIT=22,FILE=yfname(1:I-1),ERR=403,
     1             FORM='UNFORMATTED',
     2             STATUS='NEW')
c
      WRITE(22,IOSTAT=IOS,ERR=404) NREF,NSTART,NLEN,NCODNUM,
     1                             NSTARTC,NLENC,CTEXT
C
      CLOSE(21)
      CLOSE(22)
C     -----------------------------------------------------------------
C*          3.1  WRITE TABLES ON OUTPUT FILE
C                ---------------------------
 310  CONTINUE
C
c      JEND=J
c      DO 311 J=1,JEND
C
c      IPT=NSTART(J)
c      IIPT=NSTARTC(IPT)
c      WRITE(*,999) NREF(J),NLEN(J),NCODNUM(IPT),NLENC(IPT),CTEXT(IIPT)
C
c      IF(NLENC(IPT).GT.1) THEN
c         DO 312 JA=1,NLENC(IPT)-1
c         IIPT = IIPT + 1
c         WRITE(*,998) CTEXT(IIPT)
c 312     CONTINUE
c      END IF
C
c      IF(NLEN(J).GT.1) THEN
c         DO 313 JB=1,NLEN(J)-1
c         IPT = IPT + 1
c         IIPT= NSTARTC(IPT)
c         WRITE(*,997) NCODNUM(IPT),NLENC(IPT),CTEXT(IIPT)
c         IF(NLENC(IPT).GT.1) THEN
c            DO 314 JC=1,NLENC(IPT)-1
c            IIPT= IIPT + 1
c            WRITE(*,998) CTEXT(IIPT)
c 314        CONTINUE
c         END IF
c 313     CONTINUE
c      END IF
C
c 311  CONTINUE
C
      write(*,'(1h )')
      write(*,'(1H ,a,i4)') 'Total number of entries in the Table C is',
     1                       j
C
      RETURN
C     -----------------------------------------------------------------
 400  CONTINUE
C
 401  CONTINUE
C
      KERR=1
      WRITE(*,4401) IOS,yfname
 4401 FORMAT(1H ,'Open error ',i4,' on ',a)
      RETURN
C
 402  CONTINUE
      KERR=1
      WRITE(*,4402) IOS,yfname
 4402 FORMAT(1H ,'Read error ',i4,' on ',a)
      RETURN
C
 403  CONTINUE
C
      KERR=1
      WRITE(*,4403) IOS,yname
 4403 FORMAT(1H ,'Open error ',i4,' on ',a)
      RETURN
 404  CONTINUE
C
      KERR=1
      WRITE(*,4404) IOS,yname
 4404 FORMAT(1H ,'Write error ',i4,' on ',a)
      RETURN
C
  997 FORMAT(1H ,14X,I4,1X,I2,1X,A)
  998 FORMAT(1H ,22X,A)
  999 FORMAT(1H ,2X,I6,1X,I4,1X,I4,1X,I2,1X,A)
C
      END
