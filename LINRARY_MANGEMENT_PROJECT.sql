create database library_managment;
use library_managment; 
##  ************************** Publisher    *****************************************
create table publisher1( publisher_name varchar(255) primary key,  
                        publisher_address varchar(255), 
                        publisher_phone varchar(255));
select * from publisher1 ;  
##  ************************** book ***************************************** 
create table books( book_id tinyint primary key auto_increment,  
                        book_title varchar(255), 
                        publisher_name varchar(255),
                        foreign key(publisher_name) references publisher1(publisher_name) on update cascade on delete cascade ); 
select * from books;  
##  **************************book_author ***************************************** 
create table author( authorId tinyint primary key auto_increment,
                    author_book_id tinyint,  
			        Author_book_name varchar(255), 
				   foreign key(author_book_id) references books(book_id ) on update cascade on delete cascade ); 
select * from author; 

##  **************************library branch *****************************************  

create table library_branch(lib_branch_id tinyint primary key  auto_increment , 
                            lib_branchName  varchar(255), 
                            lib_branchAddress  varchar(255)) ;
select * from  library_branch ;  

##  **************************borowwer ***************************************** 

create table borrow(borrow_Card_no tinyint primary key  auto_increment , 
                            borrow_Name  varchar(255), 
                            borrow_Address  varchar(255),
                            borrow_phone  varchar(255)
                            ) auto_increment = 100;
select * from  borrow; 
 
##  **************************copies ****************************

 create table copies(copies_copiesId tinyint primary key  auto_increment, 
                            copies_book_id tinyint,
                            copies_branch_id  tinyint,
						    copies_No_of_copies  tinyint,
                            foreign key(copies_book_id) references books(book_id ) on update cascade on delete cascade ,
                            foreign key(copies_branch_id) references library_branch(lib_branch_id) on update cascade on delete cascade );
select * from  copies;  

##  **************************book loans  ****************************
  
create table book_loans( book_loan_id tinyint primary key  auto_increment, 
                            loan_book_id tinyint,
                            loan_branch_id  tinyint,
						    loan_card_No  tinyint,
                            loan_Dateout varchar(255),
                            loan_DueDate varchar(255),
                            foreign key(loan_book_id) references books(book_id ) on update cascade on delete cascade ,
                            foreign key(loan_branch_id) references library_branch(lib_branch_id) on update cascade on delete cascade,
                            foreign key(loan_card_No) references borrow(borrow_Card_no ) on update cascade on delete cascade ); 
select * from book_loans; 

#******************************** decsribe the rows**********************************************

describe book_loans;

set sql_safe_updates = 0;  # prevent data loss
#************************ peramnent COLUMN modification*************************

update book_loans 
set loan_dateout =  replace(loan_dateout,right(loan_dateout,2),concat('20',right(loan_dateout,2)))  
where book_loan_id >0; 

update book_loans set loan_dateout = replace(loan_dateout,'/','-') where book_loan_id >0 ;

update book_loans 
set loan_duedate =  replace(loan_duedate,right(loan_duedate,2),concat('20',right(loan_duedate,2)))  
where book_loan_id >0; 

update book_loans set loan_duedate = replace(loan_duedate,'/','-') where book_loan_id >0 ; 

#******************************** Type conversion ************************ 

update book_loans set loan_dateout = str_to_date(loan_dateout,'%m-%d-%Y')  where book_loan_id >0; 
update book_loans set loan_duedate= str_to_date(loan_duedate,'%m-%d-%Y')  where book_loan_id >0;

select * from publisher1 ; 
select * from books;  
 select * from author;  
 select * from  library_branch ; 
select * from  borrow; 
select * from  copies;  
select * from book_loans;  
##################################  Queations ###########################################

#1.  How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"?

 with cte1 as (select * from copies c inner join library_branch l_b  
         on  c.copies_branch_id = l_b.lib_branch_id where lib_branchName = 'sharpstown')
         select * from cte1 inner join books b on cte1.copies_book_id = b.book_id where book_title = 'the lost tribe';
         
         
# 2. How many copies of the book titled "The Lost Tribe" are owned by each library branch?

  with cte2 as (select * from books as b inner join copies  as c
         on b.book_id = c.copies_book_id where book_title = 'The lost Tribe') 
         select lib_branchName ,count(*) from cte2 inner join  library_branch  l_b on cte2.copies_branch_id = l_b.lib_branch_id  group by lib_branchName ;
         
#3.Retrieve the names of all borrowers who do not have any books checked out.  

select * from  borrow  b  left join  book_loans b_l on b.borrow_card_no = b_l.loan_card_no where loan_dateout is null ;

#4 For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18, retrieve the book title, the borrower's name, and the borrower's address. 

with cte3 as (select * from library_branch  l_b inner join  book_loans  b_l on l_b.lib_branch_id = b_l.loan_branch_id where 
 lib_branchName = 'Sharpstown' and loan_duedate = '2018-02-03'),
 cte4 as (select * from cte3 inner join borrow b on cte3.loan_card_no = b.borrow_card_no)
select b.book_title,cte4.borrow_name,cte4.borrow_Address from  books b inner join  cte4 on b.book_id = cte4.loan_book_id ;

#5 For each library branch, retrieve the branch name and the total number of books loaned out from that branch.

select l_b.lib_branchName,count(b_l.book_loan_id) as no_book_loan  from library_branch  l_b inner join  book_loans b_l  
on l_b.lib_branch_id = b_l.loan_branch_id   group by l_b.lib_branchName;

#6 Retrieve the names, addresses, and number of books checked out for all borrowers who have more than five books checked out.

select b.borrow_address,b.borrow_Name,count(b_l.loan_dateout) from borrow b inner join  book_loans  b_l on
  b.borrow_card_no = b_l.loan_card_no  group by b.borrow_address,b.borrow_Name having count(b_l.loan_dateout) >5;
  
#7 For each book authored by "Stephen King", retrieve the title and the number of copies owned by the library branch whose name is "Central".

with cte5 as (select * from  author  a inner join books  b  on a.author_book_id = b.book_id),
  cte6 as (select * from cte5 inner join copies  c  on cte5.author_book_id = c.copies_book_id) 
   select book_title,lib_branchName,count(copies_copiesId) from cte6 inner join library_branch  l_b  on cte6.copies_branch_id =l_b.lib_branch_id 
   where author_book_name = 'stephen King' and lib_branchName = 'Central' group by book_title,lib_branchName; 
   
  ######### by using the  only joins without the cte  
  
select book_title,lib_branchName,count(copies_copiesId) from  author  a inner join books  b  
on a.author_book_id = b.book_id   inner join copies c 
on a.author_book_id  = c.copies_book_id inner join library_branch  l_b
on  c.copies_branch_id=l_b.lib_branch_id 
where author_book_name = 'stephen King' and lib_branchName = 'Central'
group by book_title,lib_branchName



   
   





 

                          





                        
                        
