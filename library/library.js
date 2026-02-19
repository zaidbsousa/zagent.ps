// Library Search and Filter Functionality
(function() {
  'use strict';

  // Get DOM elements
  var searchInput = document.getElementById('searchInput');
  var filterButtons = document.querySelectorAll('.filter-btn');
  var toolCards = document.querySelectorAll('.tool-card');
  var categorySections = document.querySelectorAll('.category-section');

  if (!searchInput || filterButtons.length === 0 || toolCards.length === 0) {
    return; // Exit if elements not found
  }

  var currentCategory = 'all';
  var currentSearch = '';

  // Filter button click handler
  filterButtons.forEach(function(btn) {
    btn.addEventListener('click', function() {
      // Update active state
      filterButtons.forEach(function(b) {
        b.classList.remove('active');
      });
      this.classList.add('active');

      // Get category
      currentCategory = this.getAttribute('data-category');
      
      // Apply filters
      applyFilters();
    });
  });

  // Search input handler
  searchInput.addEventListener('input', function() {
    currentSearch = this.value.trim().toLowerCase();
    applyFilters();
  });

  // Apply both category and search filters
  function applyFilters() {
    var visibleCount = 0;

    toolCards.forEach(function(card) {
      var cardCategory = card.getAttribute('data-category');
      var cardTool = card.getAttribute('data-tool') || '';
      var cardTitle = card.querySelector('.tool-title')?.textContent || '';
      var cardDescription = card.querySelector('.tool-description')?.textContent || '';
      var cardTags = Array.from(card.querySelectorAll('.tag')).map(function(tag) {
        return tag.textContent;
      }).join(' ');

      var cardText = (cardTool + ' ' + cardTitle + ' ' + cardDescription + ' ' + cardTags).toLowerCase();

      // Category filter
      var categoryMatch = currentCategory === 'all' || cardCategory === currentCategory;

      // Search filter
      var searchMatch = currentSearch === '' || cardText.includes(currentSearch);

      // Show/hide card
      if (categoryMatch && searchMatch) {
        card.classList.remove('hidden');
        visibleCount++;
      } else {
        card.classList.add('hidden');
      }
    });

    // Show/hide category sections based on visible cards
    categorySections.forEach(function(section) {
      var sectionCategory = section.getAttribute('data-category');
      var sectionCards = section.querySelectorAll('.tool-card');
      var hasVisibleCards = false;

      sectionCards.forEach(function(card) {
        if (!card.classList.contains('hidden')) {
          hasVisibleCards = true;
        }
      });

      if (hasVisibleCards) {
        section.classList.remove('hidden');
      } else {
        // Only hide if category filter matches or is 'all'
        if (currentCategory === 'all' || sectionCategory === currentCategory) {
          section.classList.add('hidden');
        } else {
          section.classList.remove('hidden');
        }
      }
    });

    // Show message if no results
    showNoResultsMessage(visibleCount === 0);
  }

  // Show/hide no results message
  function showNoResultsMessage(show) {
    var existingMessage = document.getElementById('noResultsMessage');
    
    if (show && !existingMessage) {
      var message = document.createElement('div');
      message.id = 'noResultsMessage';
      message.className = 'code-editor fade-in';
      message.style.textAlign = 'center';
      message.style.padding = '40px 20px';
      message.innerHTML = '<pre class="code-line"><span class="comment">// لا توجد نتائج</span></pre><p style="margin-top: 16px; direction: rtl; color: var(--muted);">لم نجد أي أدوات تطابق بحثك. جرب كلمات مختلفة أو اختر فئة أخرى.</p>';
      
      var center = document.querySelector('.center');
      if (center) {
        var lastSection = center.querySelector('.category-section:last-of-type');
        if (lastSection) {
          lastSection.insertAdjacentElement('afterend', message);
        } else {
          center.appendChild(message);
        }
      }
    } else if (!show && existingMessage) {
      existingMessage.remove();
    }
  }

  // Initialize - apply filters on load
  applyFilters();
})();

