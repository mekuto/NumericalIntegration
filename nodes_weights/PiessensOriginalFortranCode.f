      SUBROUTINE KRONROD (N, A, W1, W2, EPS, IER)
c     THIS SUBROUTINE CALCULATES THE ABSCISSAS A AND WEIGHTS W1
c     OF THE (2*N+1)-POINT QUADRATURE FORMULA WHICH IS OBTAINED
c     FRCM THE N-POINT GAUSSIAN RULE BY OPTIMAL ADDITION OF
c     N+1 POINTS. THE OPTIMALLY ADDED POINTS ARE CALLED KRONROD
c     ABSCISSAS. ABSCISSAS AND WEIGHTS ARE CALCULATED FOR
c     INTEGRATION ON THE INTERVAL (-1,1).
c     SINCE THIS QUADRATURE FORMULA IS SYMMETRICAL WITH RESPECT TO THE ORIGIN,
c     ONLY THE NONNEGATIVE ABSCISSAS ARE CALCULATED. WEIGHTS CORRESPONDING
c     TO SYMMETRICAL ABSCISSAS ARE EQUAL.
c     IN ADDITION, THE WEIGHTS W2 OF THE GAUSSIAN RULE ARE CALCULATED.
C
C     INPUTPARAMETERS  
C
C     N   ORDER OF THE GAUSSIAN QUADRATURE FORMULA TO WHICH ABSCISSAS MUST BE ADDED.
C
C     EPS REQUESTED ABSOLUTE ACCURACY OF THE ABSCISSAS. THE ITERATIVE PROCESS TERMINATES
c     IF THE ABSOLUTE DIFFERENCE BETWEEN TWO SUCCESSIVE APPROXIMATIONS IS
C     LESS THAN EPS.
C
C     OUTPUT PARAMETERS
C     A   VECTOR OF DIMENSION N+1 WHICH CONTAINS THE NONNEGATIVE ABSCISSAS.
C         A(1) IS THE LARGEST ABSCISSA. A(2*K) IS A GAUSSIAN ABSCISSA.
C         A(2*K-1) IS A KRONROD ABSCISSA.
C
C     W1  VECTOR OF DIMENSION N+1 WHICH CONTAINS THE WEIGHTS CORRESPONDING TC THE
C         ABSCISSAS A.
C
C     W2  VECTCR OF DIMENSION N+1 WHICH CONTAINS THE GAUSSIAN WEIGHTS. W2(2*K-1) = 0
C         AND W2(2*K) IS THE GAUSSIAN WEIGHT CORRESPONDING TO A(2*K).
C
C     IER ERROR CODE
C     IF IER = 0 ALL ABSCISSAS ARE FOUND TO WITHIN THE REQUESTED ACCURACY.
C     IF IER = 1 ONE OF THE ABSCISSAS IS NOT FOUND AFTER 50 ITERATION STEPS
C                AND THE COMPUTATION IS TERMINATED.  
C
C     RECUIRED SUBPROGRAMS
C     ABWE1 CALCULATES THE KRONROD ABSCISSAS ANC CORRESPONDING WEIGHTS.
C     ABWE2 CALCULATES THE GAUSSIAN ABSCISSAS AND THE CORRESPONDING WEIGHTS.

      REAL*8, A, AK, AN,B,C,TAU,W1,W2,XX
      DIMENSION A(201) ,B(201) ,TAU(201) ,W1(201),W2(201)
      COMMON D, INDEX

      IER = 0
      NP = N+l
      M = (N + 1)/2
      INDEX = 1
      D = 2.00D+00
      AN = 0.00D+00

      DO 1 K=1,N
      AN = AN +1.0D0
 1    D = D*AN/(AN+0.5D0)
      DO 2 K=1,NP
 2    W2(K) = 0.0D+0

      N2 = N + N + 1
      M1 = M-1

C     CALCULATICN OF THE CHEBYSHEV COEFFICIENTS OF THE ORTHOGONAL POLYNOMIAL.
      TAU(1) = (AN+2.D0)/(AN+AN+3.0D0)
      B(M) = TA L(1)-1.0D0
      IF(N.LT.3) GOTO 4
      AK = AN
      DO 3 L = 1, M1
      AK = AK + 2.0D0
      TAU(L+1) = ((AK-1.0D0)*AK-AN*(AN+1.0D0))*(AK+2.0D0)*TAU(L)/
     1  (AK*((AK+3.0D0)*(AK+2.0D0)-AN*(AN+1.0D0)))
      ML = M-L
      B(ML) = TAU(L+1)
      DO 3 LL = 1,L
      MM = ML+LL
 3    B(ML) = B(ML)+TAU(LL)*B(MM)
 4    B(M+1) = 1.0D0

C     CALCULATICN OF APPROXIMATE VALUES FOR THE ABSCISSAS
      BB = SIN(1.570796/(SNGL(AN+AN)+1.))
      X = SQRT(1.-BB*BB)
      S = 2.*BB*X
      C = SQRT(1.-S*S)
      COEF = 1. -(1.-1./AN)/(8.*AN*AN)
      XX = COEF*X
      DO 5 K = 1,N,2

C     CALCULATICN OF THE K-TH ABSCISSA (KRONROD AESCISSA) AND THE CORRESPONDING WEIGHT.
      CALL ABWE1(XX,B,M,EPS,W1(K),N,IER)
      IF(IER.EQ.1) RETURN
      A(K) = XX
      Y = X
      X = Y*C-BB*S
      BB = Y*S + BB*C
      XX = COEF*X
      IF(K.EQ.N) XX = 0.0D0

C     CALCULATICN CF THE (K+1)-TH ABSCISSA (GAUSSIAN ABSCISSA) AND THE CORRESPONDING WEIGHTS.
      CALL ABWE2(XX,B,M,EPS,W1(K+1),W2(K+1),N,IER)
      IF( IER.EQ.1) RETURN
      A(K+1) = XX
      Y = X
      X = Y*C-BB*S
      BB = Y*S + B8*C

 5    XX = COEF*X
      IF( INDEX.EQ.1) GOTO 6
      A(N+1) = 0.0D0
      CALL ABWE1(A(N+1),B,M,EPS,W1(N+l),N,IER)

 6    RETURN
      END


      SUBROUTINE ABWE1(X,A,N,EPS,W,N1,IER)
      REAL*8 A,AI,B0,B1,B2,COEF,D0,D1,D2,DELTA,F,FD,W,X,YY
      DIMENSION A(201)
      COMMON COEF, INDEX
      ITER = 0
      KA = 0
      IF(X.EQ.0.0D0) KA = 1

 1    ITER = ITER+1

C     START ITERATIVE PROCESS FOR THE COMPUTATION OF A KRONROD ABSCISSA.
C     TEST ON THE NUMBER OF ITERATION STEPS

      IF(ITER.LT.50) GOTO 2
      IER = 1
      RETURN
 2    B1 = 0.0D0
      B2 = A(N+1)
      YY = 4.D0*X*X-2.0D0
      D1 = 0.0D0
      IF(INDEX.EQ.1) GOTO 3
      AI = N+N+1
      D2 = AI*A(N+1)
      DIF = 2.D0
      GOTO 4
 3    AI = N+1
      D2 = 0.0D0
      DIF = 1.D0
 4    DO 5 K=1,N
      AI = AI-DIF
      I = N-K+1
      B0 = B1
      B1 = B2
      D0 = D1
      D1 = D2
      B2 = YY*81-B0+A(I)
      I = I+INDEX
 5    D2 = YY*D1-D0 + AI*A(I)
      IF(INCEX.EQ.1) GOTO 6
      F = X*(82-B1)
      FD = C2+D1
      GOTO 7
 6    F = 0.5D0*(B2-BO)
      FD = 4.D0*X*C2
 7    DELTA = F/FD
      X = X-DELTA
      IF(KA.EQ.1) GOTO 8

C     TEST ON CONVERGENCE.
      IF(DABS(DELTA).GT.EPS) GOTO 1
      KA = 1
      GOTO 1

C     CCMPUTATION OF THE WEIGHT.
 8    D0 = 1.D0
      D1 = X
      AI = 0.0D+0
      DO 9 K = 2,N1
      AI = AI+1.D+0
      D2 = ((AI+AI+1.D+0)*X*D1-AI*D0)/(AI+1.D+0)
 9    D0 = C1
      C1 = C2
      W = COEF/(FD*D2)
      RETURN
      END


      SUBROUTINE ABWE2(X,A,N,EPS,W1,W2,N1,IER)
      REAL*8 A,AN,COEF,DELTA,P0,P1,P2,PD0,PD1,PD2,W1,W2,X,YY
      DIMENSION A(201)
      COMMON COEF,INDEX
      ITER = 0
      KA = 0
      IF(X.EQ.0.0D0) KA=1

C     START ITERATIVE PROCESS FOR THE COMPUTATION OF A GAUSSIAN ABSCISSA.
 1    ITER = ITER + 1

C     TEST CN THE NUMBER CF ITERATION STEPS.
      IF ( ITER.LT.50) GOTO 2
      IER = 1
      RETURN
 2    P0 = 1.D0
      PI = X
      PD0 = 0.D0
      PD1 = 1.0D+0
      AI = 0.0D+0
      DO 3 K = 2,N1
      AI = AI+1.D0
      P2 = ((AI+AI+1.D0)*X*P1-AI*P0)/(AI+1.D0)
      PD2 = ((AI+AI+1.D+0)*(P1+X*PD1)-AI*PD0)/(AI+1.D0)
      P0 = P1
      P1 = P2
      PD0 = PD1
 3    PD1 = PD2
      DELTA = P2/PD2
      X = X-DELTA
      IF(KA.EQ.1) GOTO 4

C     TEST ON CONVERGENCE.
      IF(DABS(DELTA).GT.EPS) GOTO 1
      KA = 1
      GOTO 1
 4    N = N1

C     COMPUTATICN OF THE GAUSSIAN WEIGHT.
      W2 = 2.D0/(AN*PD2*P0)
      P1 = 0.0D0
      P2 = A(N+1)
      YY = 4.0D0*X*X-2.D0
      DO 5 K=1,N
      I = N-K+l
      P0 = P1
      P1 = P2
 5    P2 = YY*P1-P0+A(I)
      IF (INDEX.EQ.1) GOTO 6

C     COMPUTATION OF THE OTHER WEIGHT.
      W1 = COEF /(PD2*X*(P2-P1))+W2
      GOTO 7
 6    W1 = 2.D0*COEF/(PD2*(P2-P0))+W2
 7    RETURN
      END