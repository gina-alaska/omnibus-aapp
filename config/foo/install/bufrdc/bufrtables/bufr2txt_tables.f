      PROGRAM BUFR2TXT_TABLES
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
C**** *BUFR2TXT_TABLES*
C
C
C     PURPOSE.
C     --------
C        Unpacks input bufr tables in bufr form and creates
C        text version of bufr tables and binary bufr tables
C        used by bufr software.
C
C
C**   INTERFACE.
C     ----------
C
C          NONE.
C
C     METHOD.
C     -------
C
C          NONE.
C
C
C     EXTERNALS.
C     ----------
C
C         CALL BUFREX
C
C     REFERENCE.
C     ----------
C
C          NONE.
C
C     AUTHOR.
C     -------
C
C          M. DRAGOSAVAC    *ECMWF*       15/07/97.
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
      PARAMETER (KELEM=80000)
      PARAMETER (KVALS=360000)
C 
      DIMENSION KBUFF(JBUFL)
      DIMENSION KBUFR(JBUFL)
      DIMENSION KSUP(JSUP)  ,KSEC0(JSEC0),KSEC1(JSEC1)
      DIMENSION KSEC2(JSEC2),KSEC3(JSEC3),KSEC4(JSEC4)
      DIMENSION KEY  (JKEY),KREQ(2)
C
      REAL*8 VALUES(KVALS),VALUE(KVALS)
      DIMENSION KTDLST(JELEM),KTDEXP(JELEM),KRQ(KELEM)
      REAL*8 RQV(KELEM)
      DIMENSION KDATA(200),KBOXR(JELEM*4)
      REAL*8 VALS(KVALS)
C
      CHARACTER*256 CF,COUT,CARG(4)
      CHARACTER*64 CNAMES(KELEM),CBOXN(JELEM*4)
      CHARACTER*24 CUNITS(KELEM),CBOXU(JELEM*4)
      CHARACTER*80 CVALS(KVALS)
      CHARACTER*80 CVAL(KVALS)
      CHARACTER*80 YENC
      REAL*8 EPS, RVIND
c
C     ------------------------------------------------------------------
C*          1. INITIALIZE CONSTANTS AND VARIABLES.
C              -----------------------------------
 100  CONTINUE
C
C     Missing value indicator
C 
      NBYTPW=JBPW/8
      RVIND=1.7E38
      nvind=2147483647
      EPS=10.E-10
      NPACK=0
      N=0
      OO=.FALSE.
C
C     Input file name
C
C     Get input and output file name.
C
      NARG=IARGC()
c
      IF(NARG.NE.2) THEN
         print*,'Usage -- bufr2txt_tables -i infile ' 
         stop
      END IF
c
      do 101 j=1,narg
      call getarg(j,carg(j))
 101  continue
c
      if(carg(1).ne.'-i'.and.carg(1).ne.'-I'.or.
     1   carg(2).eq.' ') then
         print*,'Usage -- bufr2txt_tables -i inpfile '
         stop
      end if
c
      cf=carg(2)
      ii=index(cf,' ')
c
      KRQL=0
      NR=0
      KREQ(1)=0
      KREQ(2)=0
C
C*          1.2 OPEN FILE CONTAINING BUFR DATA.
C               -------------------------------
 120  CONTINUE
C
      IRET=0 
      CALL PBOPEN(IUNIT,CF(1:ii),'r',IRET)
      IF(IRET.EQ.-1) STOP 'open failed'
      IF(IRET.EQ.-2) STOP 'Invalid file name'
      IF(IRET.EQ.-3) STOP 'Invalid open mode specified'
C
C     ----------------------------------------------------------------- 
C*          2. SET REQUEST FOR EXPANSION.
C              --------------------------
 200  CONTINUE
C
C
C
C     -----------------------------------------------------------------
C*          3.  READ BUFR MESSAGE.
C               ------------------
 300  CONTINUE
C
      IERR=0
      KBUFL=0
C
      IRET=0
      CALL PBBUFR(IUNIT,KBUFF,JBUFL,KBUFL,IRET) 
      IF(IRET.EQ.-1) THEN
c         IF(N.NE.0) GO TO 600
         print*,'Number of messages    ',n
         STOP 'EOF'
      END IF
      IF(IRET.EQ.-2) STOP 'File handling problem' 
      IF(IRET.EQ.-3) STOP 'Array too small for product'
C
      N=N+1
       print*,'----------------------------------',n
      KBUFL=KBUFL/nbytpw+1
C
C     -----------------------------------------------------------------
C*          4. EXPAND BUFR MESSAGE.
C              --------------------
 400  CONTINUE
C
      CALL BUS012(KBUFL,KBUFF,KSUP,KSEC0,KSEC1,KSEC2,KERR)
      IF(KERR.NE.0) THEN
         PRINT*,'Error in BUS012: ',KERR
         PRINT*,' BUFR MESSAGE NUMBER ',N,' CORRUPTED.'
         KERR=0
         GO TO 300
      END IF
C
      IF(KSUP(6).GT.1) THEN
         KEL=JWORK/KSUP(6)
         IF(KEL.GT.KELEM) KEL=KELEM
      ELSE 
         KEL=KELEM
      END IF
C
      CALL BUFREX(KBUFL,KBUFF,KSUP,KSEC0 ,KSEC1,KSEC2 ,KSEC3 ,KSEC4,
     1            KEL,CNAMES,CUNITS,KVALS,VALUES,CVALS,IERR)
C
      print*,'ierr=',ierr
      IF(IERR.NE.0) call exit(2)
C
C*            5. Create text and binary Bufr tables
C                ----------------------------------
 500  continue
c
      CALL BUSEL(KTDLEN,KTDLST,KTDEXL,KTDEXP,KERR)
      IF(KERR.NE.0) CALL EXIT(2)
c
      CALL BUTABLES(KSUP,KSEC1,KTDLEN,KTDLST,KTDEXL,KTDEXP,
     1             VALUES,CVALS,KERR)
      if(kerr.ne.0) call exit(2)
c
      GO TO 300
C     -----------------------------------------------------------------
C
 810  CONTINUE
C
      WRITE(*,'(1H ,A)') 'OPEN ERROR ON INPUT FILE'
      GO TO 900
C      
 800  CONTINUE
C
      IF(iret.EQ.-1) THEN
         print*,'Number of records processed ',n
      ELSE
         print*,' BUFR : error= ',ierr
      END IF
C
 900  CONTINUE
C
      CALL PBCLOSE(IUNIT,IRET)
      CALL PBCLOSE(IUNIT1,IRET)
C
      END
      SUBROUTINE BUTABLES(KSUP,KSEC1,KTDLEN,KTDLST,KTDEXL,KTDEXP,
     1                   VALUES,CVALS,KERR)
C
C**** *BUTABLES*
C
C
C     PURPOSE.
C     --------
C         Create text and binary Bufr tables from Bufr data.
C
C
C**   INTERFACE.
C     ----------
C
C          CALL BUTABLES(KSEC1,KTDLEN,KTDLST,KTDEXL,KTDEXP,
C                       KVALS,VALUES,CVALS,KERR)
C
C     METHOD.
C     -------
C
C          NONE.
C
C
C     EXTERNALS.
C     ----------
C
C         CALL BUSEL
C         CALL BUFREX
C         CALL BUFREN
C         CALL BUPRS0
C         CALL BUPRS1
C         CALL BUPRS2
C         CALL BUPRS3
C         CALL BUPRT
C         CALL BUUKEY
C
C     REFERENCE.
C     ----------
C
C          NONE.
C
C     AUTHOR.
C     -------
C
C          M. DRAGOSAVAC    *ECMWF*       15/09/87.
C
C
C     MODIFICATIONS.
C     --------------
C
C          NONE.
C
C
      IMPLICIT LOGICAL(O,G), CHARACTER*8(C,H,Y)
C
      dimension ksec1(*),ktdlst(*),ktdexp(*),ksup(*)
      real*8 values(*), rvind
      character*80 cvals(*)
c
      character*120 crec
      character*256 YFNAME
      character*21 YTABB,YTABC,YTABD
C                                                                       
C     ------------------------------------------------------------------
C*          1. Initialize constants and variables.
C              -----------------------------------
 100  continue
C
C     Missing value indicator
C 
      IREP=0
      RVIND=1.7E38
      NVIND=2147483647
c
C             BUFR EDITION 2 NAMING CONVENTION
C
C             BXXXXXYYZZ , CXXXXXYYZZ , DXXXXXYYZZ
C
C             B      - BUFR TABLE 'B'
C             C      - BUFR TABLE 'C'
C             D      - BUFR TABLE 'D'
C             XXXXX  - ORIGINATING CENTRE
C             YY     - VERSION NUMBER OF MASTER TABLE
C                      USED( CURRENTLY 2 )
C             ZZ     - VERSION NUMBER OF LOCAL TABLE USED
C
C             BUFR EDITION 3 NAMING CONVENTION
C
C             BWWWXXXYYZZ , CWWWXXXYYZZ , DWWWXXXYYZZ
C
C             B      - BUFR TABLE 'B'
C             C      - BUFR TABLE 'C'
C             D      - BUFR TABLE 'D'
C             WWW    - ORIGINATING SUB-CENTRE
C             XXX    - ORIGINATING CENTRE
C             YY     - VERSION NUMBER OF MASTER TABLE
C                      USED( CURRENTLY 2 )
C             ZZ     - VERSION NUMBER OF LOCAL TABLE USED
C
C
C             BUFR EDITION 4 NAMING CONVENTION
C
C             BSSSWWWWWXXXXXYYYZZZ , CSSSWWWWWXXXXXYYYZZZ , DSSSWWWWWXXXXXYYYZZZ
C
C             B      - BUFR TABLE 'B'
C             C      - BUFR TABLE 'C'
C             D      - BUFR TABLE 'D'
C             SSS    - MASTER TABLE
C             WWWWWW - ORIGINATING SUB-CENTRE
C             XXXXXX - ORIGINATING CENTRE
C             YYY    - VERSION NUMBER OF MASTER
C                      TABLE USED( CURRENTLY 12 )
C             ZZZ    - VERSION NUMBER OF LOCAL TABLE USED

         IXX=KSEC1(3)
         IYY=KSEC1(15)
         IZZ=KSEC1(08)
         IF(KSEC1(2).EQ.3) THEN
            IWW=KSEC1(16)
            ISS=KSEC1(14)
         ELSEIF(KSEC1(2).EQ.4) THEN
            IWW=KSEC1(16)
            ISS=KSEC1(14)
         ELSE
            IWW=0
            ISS=0
         END IF
C
C     IF STANDARD TABLES USED, USE ECMWF ORIGINATING CENTRE ID
C
         IF(KSEC1(8).EQ.0.OR.KSEC1(8).EQ.255) THEN
            IXX=98
            IWW=0
            IZZ=0
         ENDIF
C
      if(ksec1(2).ge.3) then
         WRITE(YTABB,'(A1,I3.3,2(I5.5),I3.3,I3.3)')
     1         'B',ISS,IWW,IXX,IYY,IZZ
         WRITE(YTABC,'(A1,I3.3,2(I5.5),I3.3,I3.3)')
     1         'C',ISS,IWW,IXX,IYY,IZZ
         WRITE(YTABD,'(A1,I3.3,2(I5.5),I3.3,I3.3)')
     1         'D',ISS,IWW,IXX,IYY,IZZ
         iend=20
      else
         WRITE(YTABB,'(A1,I5.5,I2.2,I2.2)') 'B',IXX,IYY,IZZ
         WRITE(YTABC,'(A1,I5.5,I2.2,I2.2)') 'C',IXX,IYY,IZZ
         WRITE(YTABD,'(A1,I5.5,I2.2,I2.2)') 'D',IXX,IYY,IZZ
         iend=10
      end if
C
      if(ksec1(7).eq.1.or.ksec1(17).eq.1) then
C
C        Bufr table B
C
         yfname=YTABB(1:iend)//'.TXT'
         PRINT*,'BUFR Tables to be created ',yfname
         open(unit=67,file=yfname,status='unknown',iostat=ios,err=500)
C
c
c           1.1 Find replication factors if any
c
         do 101 i=1,ktdexl
         if(ktdexp(i).eq.031001.or.ktdexp(i).eq.031002) then
            irep=nint(values(i))
            go to 102
         end if
 101     continue
c
 102     continue
c
c           1.2 Find first F descriptor
c
 120     continue
c
         do 121 i=1,ktdexl
         if(ktdexp(i).eq.000010) then
            ist=i
            go to 122
         end if
 121     continue
c
 122     continue
c
         do 201 i=1,irep
         crec=' '
c
c         F DESCRIPTOR TO BE ADDED OR DEFINED
C
         icv=nint(values(ist)/1000)      ! index to cval array
         iln=nint(values(ist))-icv*1000  ! length if chatacter string
         crec(2:2)=cvals(icv)(1:iln)
c
c         X DESCRIPTOR TO BE ADDED OR DEFINED   
c
         icv=nint(values(ist+1)/1000)      ! index to cval array
         iln=nint(values(ist+1))-icv*1000  ! length if chatacter string
         crec(3:4)=cvals(icv)(1:iln)
c
c         Y DESCRIPTOR TO BE ADDED OR DEFINED   
c
         icv=nint(values(ist+2)/1000)      ! index to cval array
         iln=nint(values(ist+2))-icv*1000  ! length if chatacter string
         crec(5:7)=cvals(icv)(1:iln)
c
c         ELEMENT NAME, LINE 1 
c
         icv=nint(values(ist+3)/1000)      ! index to cval array
         iln=nint(values(ist+3))-icv*1000  ! length if chatacter string
         crec(9:40)=cvals(icv)(1:iln)
c
c         ELEMENT NAME, LINE 2 
c
         icv=nint(values(ist+4)/1000)      ! index to cval array
         iln=nint(values(ist+4))-icv*1000  ! length if chatacter string
         crec(41:72)=cvals(icv)(1:iln)
c
c         UNITS NAME
c
         icv=nint(values(ist+5)/1000)      ! index to cval array
         iln=nint(values(ist+5))-icv*1000  ! length if chatacter string
         crec(74:97)=cvals(icv)(1:iln)
         if(crec(74:83).eq.'CODE TABLE'.or.
     1      crec(74:83).eq.'FLAG TABLE') then
            crec(85:90)=crec(2:7)
         end if
c
c         UNITS SCALE SIGN
c
         icv=nint(values(ist+6)/1000)      ! index to cval array
         iln=nint(values(ist+6))-icv*1000  ! length if character string
         yscale(1:1)=cvals(icv)(1:iln)
         if(yscale(1:1).eq.'+') yscale(1:1)=' '
c
c         UNITS SCALE
c
         icv=nint(values(ist+7)/1000)      ! index to cval array
         iln=nint(values(ist+7))-icv*1000  ! length if chatacter string
         iii=101
         do 112 ii=iln,1,-1
         crec(iii:iii)=cvals(icv)(ii:ii)
         if(cvals(icv)(ii:ii).ne.' ') iii=iii-1
 112     continue
         crec(iii:iii)=yscale(1:1)

c
c         UNITS REFERENCE SIGN
c
         icv=nint(values(ist+8)/1000)      ! index to cval array
         iln=nint(values(ist+8))-icv*1000  ! length if chatacter string
         yref(1:1)=cvals(icv)(1:iln)
         if(yref(1:1).eq.'+') yref(1:1)=' '
c
c         UNITS REFERENCE VALUE
c
         icv=nint(values(ist+9)/1000)      ! index to cval array
         iln=nint(values(ist+9))-icv*1000  ! length if chatacter string
         iii=114
         do 111 ii=iln,1,-1
         crec(iii:iii)=cvals(icv)(ii:ii)
         if(cvals(icv)(ii:ii).ne.' ') iii=iii-1
 111     continue
         crec(iii:iii)=yref(1:1)
c
c         ELEMENT DATA WIDTH
c
         icv=nint(values(ist+10)/1000)      ! index to cval array
         iln=nint(values(ist+10))-icv*1000  ! length if chatacter string
         iii=118
         do 113 ii=iln,1,-1
         crec(iii:iii)=cvals(icv)(ii:ii)
         if(cvals(icv)(ii:ii).ne.' ') iii=iii-1
 113     continue

c
         ist=ist+11
         print*,crec
         write(67,'(a)',iostat=ios,err=400) crec
c
 201     continue
c
         close(67)
C
      elseif(ksec1(7).eq.2.or.ksec1(17).eq.2) then
C
C           Bufr table D
C
         yfname=YTABD(1:iend)//'.TXT'
         PRINT*,'BUFR Table to be created ',yfname
         open(unit=68,file=yfname,status='unknown',iostat=ios,err=500)
c
         ist=8
         irep=1
         if(ktdexp(8).eq.31001.or.ktdexp(8).eq.31002) then
            irep=nint(values(8))
            ist=9
         end if
c
         
         inc=0
         do 301 i=1,irep
         crec=' '
c
c         F DESCRIPTOR TO BE ADDED OR DEFINED
C
         icv=nint(values(ist)/1000)      ! index to cval array
         iln=nint(values(ist))-icv*1000  ! length if chatacter string
         crec(2:2)=cvals(icv)(1:iln)
c
c         X DESCRIPTOR TO BE ADDED OR DEFINED
c
         inc=inc+1
         icv=nint(values(ist+inc)/1000)      ! index to cval array
         iln=nint(values(ist+inc))-icv*1000  ! length if chatacter string
         crec(3:4)=cvals(icv)(1:iln)
c
c         Y DESCRIPTOR TO BE ADDED OR DEFINED
c
         inc=inc+1
         icv=nint(values(ist+inc)/1000)      ! index to cval array
         iln=nint(values(ist+inc))-icv*1000  ! length if chatacter string
         crec(5:7)=cvals(icv)(1:iln)
c
c        Number of sequences
c
         inc=inc+1
         irep1=nint(values(ist+inc))
         write(crec(8:10),'(i3)') irep1
c
c        First in sequence
c
         inc=inc+1
         icv=nint(values(ist+inc)/1000)       ! index to cval array
         iln=nint(values(ist+inc))-icv*1000  ! length if chatacter string
         crec(12:17)=cvals(icv)(1:iln)
c
         write(*,'(a)') crec
         write(68,'(a)') crec
c
         do 302 j=1,irep1-1
         crec=' '
         inc=inc+1
         icv=nint(values(ist+inc)/1000)       ! index to cval array
         iln=nint(values(ist+inc))-icv*1000  ! length if chatacter string
         crec(12:17)=cvals(icv)(1:iln)
         write(*,'(a)') crec
         write(68,'(a)') crec
 302     continue
c
         ist=ist+inc+1
         inc=0
c
 301     continue
c
         close(68)
         return
c
      else
         kerr=1
         print*,'Not known table.'
         call exit(2)
      end if
c
      return
c
 400  continue
c
      print*,'Write error ',ios
      return
c
 500  continue
c
      print*,'Open error ',ios
      return
      end
