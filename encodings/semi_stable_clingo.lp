%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Encoding for semi-stable extensions
% from Database and Artificial Intelligence Group at TU Wien
% https://www.dbai.tuwien.ac.at/research/argumentation/aspartix/dung.html
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Guess a set S \subseteq A
in(X) :- not out(X), arg(X).
out(X) :- not in(X), arg(X).

%% S has to be conflict-free
:- in(X), in(Y), att(X,Y).

%% The argument x is defeated by the set S
defeated(X) :- in(Y), att(Y,X).

%% The argument x is not defended by S
not_defended(X) :- att(Y,X), not defeated(Y).

%% All arguments x \in S need to be defended by S (admissibility)
:- in(X), not_defended(X).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For the remaining part we need to put an order on the domain.
% Therefore, we define a successor-relation with infinum and supremum 
% as follows 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lt(X,Y) :- arg(X),arg(Y), X<Y, not input_error.
nsucc(X,Z) :- lt(X,Y), lt(Y,Z).
succ(X,Y) :- lt(X,Y), not nsucc(X,Y).
ninf(X) :- lt(Y,X).
nsup(X) :- lt(X,Y).
inf(X) :- not ninf(X), arg(X).
sup(X) :- not nsup(X), arg(X).

%% Guess S' \supseteq S for semi-stable
inN(X) | outN(X) :- arg(X), not input_error.

% eqplus checks wheter S'+ equals S+
eqplus_upto(Y) :- inf(Y), in(Y), inN(Y).
eqplus_upto(Y) :- inf(Y), in(Y), inN(X), att(X,Y).
eqplus_upto(Y) :- inf(Y), in(X), inN(Y), att(X,Y).
eqplus_upto(Y) :- inf(Y), in(X), inN(Z), att(X,Y), att(Z,Y).
eqplus_upto(Y) :- inf(Y), out(Y), outN(Y), not defeated(Y), undefeated(Y).
eqplus_upto(Y) :- succ(Z,Y), in(Y), inN(Y), eqplus_upto(Z).
eqplus_upto(Y) :- succ(Z,Y), in(Y), inN(X), att(X,Y), eqplus_upto(Z).
eqplus_upto(Y) :- succ(Z,Y), in(X), inN(Y), att(X,Y), eqplus_upto(Z).
eqplus_upto(Y) :- succ(Z,Y), in(X), inN(U), att(X,Y), att(U,Y), eqplus_upto(Z).
eqplus_upto(Y) :- succ(Z,Y), out(Y), outN(Y), not defeated(Y), undefeated(Y), eqplus_upto(Z).

eqplus :- sup(Y), eqplus_upto(Y).

%% get those X \notin S' which are not defeated by S'
%% using successor again...

undefeated_upto(X,Y) :- inf(Y), outN(X), outN(Y).
undefeated_upto(X,Y) :- inf(Y), outN(X),  not att(Y,X).

undefeated_upto(X,Y) :- succ(Z,Y), undefeated_upto(X,Z), outN(Y).
undefeated_upto(X,Y) :- succ(Z,Y), undefeated_upto(X,Z), not att(Y,X).

undefeated(X) :- sup(Y), undefeated_upto(X,Y).

%% spoil if the AF is empty
not_empty :- arg(X).
spoil :- not not_empty.


%% spoil if S'+ equals S+
spoil :- eqplus.

%% S' has to be conflictfree - otherwise spoil
spoil :- inN(X), inN(Y), att(X,Y).

%% spoil if not semi-stable
spoil :- inN(X), outN(Y), att(Y,X), undefeated(Y).
spoil :- in(X), outN(X), undefeated(X).
spoil :- in(Y), att(Y,X), outN(X), undefeated(X).

inN(X) :- spoil, arg(X).
outN(X) :- spoil, arg(X).

%% do the final spoil-thing ...
:- not spoil.