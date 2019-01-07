$('.pagination-demo').twbsPagination({
//<!-- Enter here -->
totalPages: 2,
//<!-- Enter here -->
// the current page that show on start
startPage: 1,

// maximum visible pages
visiblePages: 6,

initiateStartPageClick: true,

// template for pagination links
href: false,

// variable name in href template for page number
hrefVariable: '{{number}}',

// Text labels
first: 'First',
prev: 'Previous',
next: 'Next',
last: 'Last',

// carousel-style pagination
loop: false,

// callback function
onPageClick: function (event, page) {
	$('.page-active').removeClass('page-active');
  $('#page'+page).addClass('page-active');
},

// pagination Classes
paginationClass: 'pagination',
nextClass: 'next',
prevClass: 'prev',
lastClass: 'last_btn',
firstClass: 'first_btn',
pageClass: 'page',
activeClass: 'active',
disabledClass: 'disabled'

});
