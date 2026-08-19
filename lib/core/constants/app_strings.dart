/// All user-facing copy lives here — widgets never hardcode text.
abstract final class AppStrings {
  // App
  static const appName = 'Task Manager';

  // Sign in
  static const signInTitle = 'Welcome back';
  static const signInSubtitle = 'Sign in to sync your tasks across devices.';
  static const signInWithGoogle = 'Continue with Google';
  static const signInFailed = 'Sign-in failed. Please try again.';
  static const signOut = 'Sign out';

  // Task list
  static const tasksTitle = 'My Tasks';
  static const searchHint = 'Search tasks by title';
  static const filterAll = 'All';
  static const filterCompleted = 'Completed';
  static const filterPending = 'Pending';
  static const sortByDueDate = 'Due date';
  static const sortByPriority = 'Priority';
  static const sortLabel = 'Sort by';
  static const emptyTitle = 'No tasks yet';
  static const emptySubtitle = 'Tap + to create your first task.';
  static const emptyFilteredTitle = 'Nothing matches';
  static const emptyFilteredSubtitle = 'Try a different search or filter.';
  static const errorTitle = 'Something went wrong';
  static const errorSubtitle = 'We couldn\'t load your tasks.';
  static const retry = 'Retry';
  static const deleteTaskTitle = 'Delete task?';
  static const deleteTaskBody = 'This can\'t be undone.';
  static const cancel = 'Cancel';
  static const delete = 'Delete';

  // Add/edit task
  static const addTaskTitle = 'New Task';
  static const editTaskTitle = 'Edit Task';
  static const fieldTitle = 'Title';
  static const fieldDescription = 'Description';
  static const fieldPriority = 'Priority';
  static const fieldDueDate = 'Due date';
  static const save = 'Save';
  static const titleRequired = 'Title is required';
  static const titleTooLong = 'Title must be under 120 characters';
  static const descriptionTooLong = 'Description must be under 2000 characters';
  static const dueDateRequired = 'Please pick a due date';

  // Task detail
  static const detailTitle = 'Task Details';
  static const markComplete = 'Mark as complete';
  static const markPending = 'Mark as pending';
  static const edit = 'Edit';
  static const created = 'Created';
  static const due = 'Due';
  static const status = 'Status';
  static const statusCompleted = 'Completed';
  static const statusPending = 'Pending';

  // Sync indicator
  static const syncedLabel = 'Synced';
  static const syncingLabel = 'Syncing…';
  static const offlineLabel = 'Offline';
  static const pendingSyncLabel = 'pending';
  static const syncErrorLabel = 'Sync error';
}
