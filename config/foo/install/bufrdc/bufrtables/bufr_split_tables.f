      PROGRAM BUFR_SPLIT_TABLES
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
C**** *BUFR_SPLIT_TABLES*
C
C
C     PURPOSE.
C     --------
C
C           Splits bufr source text bufr tables into 
C           standard wmo table and local table
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
      CHARACTER*256 CF1,CF2,CF3,carg(4)
      character*120 record
c
C                                                                       
C     ------------------------------------------------------------------
C*          1. INITIALIZE CONSTANTS AND VARIABLES.
C              -----------------------------------
 100  CONTINUE
C
C     Input file name
C
C     Get input and output file name.
C
      narg=IARGC()
c
      IF(narg.NE.2) THEN
         print*,'Usage -- bufr_split_tables -i infile ' 
         stop
      END IF
c
      do 101 j=1,narg
      call getarg(j,carg(j))
 101  continue
c
      if(carg(1).ne.'-i'.and.carg(1).ne.'-I'.or.
     1   carg(2).eq.' ') then
         print*,'Usage -- bufr_split_tables -i inpfile '
         stop
      end if
c
      cf1=carg(2)
      ii=index(cf1,' ')
      if(ii.gt.1) ii=ii-1
      cf2='L'//cf1(2:ii)
      cf3=cf1(1:II-6)//'00.TXT'
C
C*          1.2 OPEN FILE CONTAINING BUFR DATA.
C               -------------------------------
 120  CONTINUE
C
      iunit1=23
      iunit2=24
      iunit3=25
      open(iunit1,file=cf1(1:ii),status='old',
     1            recl=120,form='formatted')
      open(iunit2,file=cf2(1:ii),status='unknown',
     1            recl=120,form='formatted')
      open(iunit3,file=cf3(1:ii),status='unknown',
     1            recl=120,form='formatted')
C
C     ----------------------------------------------------------------- 
C*          3.  READ BUFR TABLE
C               ------------------
 300  CONTINUE
C
      read(iunit1,'(a)',end=400) record
      read(record(5:7),'(i3)')  ix
c
      if(cf1(1:1).eq.'B') then
         if(ix.ge.193) then
            write(iunit2,'(a)') record
         else
            write(iunit3,'(a)') record
         end if
      elseif(cf1(1:1).eq.'D') then
         if(ix.ge.193) then
            read(record(8:10),'(i3)') iloop
            write(iunit2,'(a)') record
            do i=1,iloop-1
            read(iunit1,'(a)',end=400) record
            write(iunit2,'(a)') record
            end do
         else
            read(record(8:10),'(i3)') iloop
            write(iunit3,'(a)') record
            do i=1,iloop-1
            read(iunit1,'(a)',end=400) record
            write(iunit3,'(a)') record
            end do
         end if
      else
         print*,'The table has not been split'
         go to 400
      end if
C
      go to 300
C
C     -----------------------------------------------------------------
C*          4. Close files
C              --------------------
 400  CONTINUE
C
      close(iunit1)
      close(iunit2)
      close(iunit3)      
C     -----------------------------------------------------------------
C
C
C
      END
