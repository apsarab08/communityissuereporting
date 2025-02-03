from flask import Flask, render_template, request, redirect, url_for, session, flash
from flask_mysqldb import MySQL
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename
from functools import wraps
import os
import datetime
import logging
import mysql.connector


# Setup logging
from MySQLdb import IntegrityError

app = Flask(__name__)
app.secret_key = 'your_secret_key'

# MySQL configurations
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'Appu@123'
app.config['MYSQL_DB'] = 'CommunityIssueReporting'
app.config['MYSQL_CURSORCLASS'] = 'DictCursor'

mysql = MySQL(app)
logging.basicConfig(level=logging.DEBUG)

# Ensure the 'uploads' folder exists
os.makedirs(os.path.join('static', 'uploads'), exist_ok=True)

# Admin-only decorator
def admin_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user' not in session or session['user']['role'] != 'Admin':
            flash('You do not have permission to access this page.', 'error')
            return redirect(url_for('index'))
        return f(*args, **kwargs)
    return decorated_function

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']

        cursor = mysql.connection.cursor()
        cursor.execute('SELECT * FROM Users WHERE email = %s', (email,))
        user = cursor.fetchone()
        cursor.close()

        if user and check_password_hash(user['password'], password):
            session['user'] = {
                'user_id': user['user_id'],
                'email': user['email'],
                'role': user['role']  # Store user role in session
            }

            if user['role'] == 'Admin':
                return redirect(url_for('admin_dashboard'))
            else:
                return redirect(url_for('index'))
        else:
            flash('Invalid credentials', 'error')

    return render_template('login.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        name = request.form['name']
        email = request.form['email']
        password = generate_password_hash(request.form['password'])
        role = request.form['role']
        cursor = mysql.connection.cursor()
        cursor.execute('INSERT INTO Users (name, email, password, role) VALUES (%s, %s, %s, %s)',
                       (name, email, password, role))
        mysql.connection.commit()

        cursor.close()

        return redirect(url_for('login'))
    return render_template('register.html', success_message='Registration successful! Please log in.')

@app.route('/logout')
def logout():
    session.pop('user', None)
    return redirect(url_for('index'))

@app.route('/report_issue', methods=['GET', 'POST'])
def report_issue():
    if request.method == 'POST':
        category_id = request.form.get('category_id')
        description = request.form.get('description')
        location = request.form.get('location')

        if 'images' in request.files:
            images = request.files.getlist('images')
            image_filenames = []
            for image in images:
                filename = secure_filename(image.filename)
                image.save(os.path.join('static', 'uploads', filename))
                image_filenames.append(filename)

            images_str = ','.join(image_filenames)
        else:
            images_str = ''

        # Validate category_id exists
        if not category_id:
            return redirect(url_for('report_issue_form', error='Category is required'))

        # Insert into Problems table
        cursor = mysql.connection.cursor()
        cursor.execute(
            'INSERT INTO Problems (user_id, category_id, description, location, status, reported_date, images) VALUES (%s, %s, %s, %s, %s, NOW(), %s)',
            (session['user']['user_id'], category_id, description, location, 'Reported', images_str)
        )
        mysql.connection.commit()
        cursor.close()

        return redirect(url_for('view_issues'))

    cursor = mysql.connection.cursor()
    cursor.execute('SELECT * FROM Categories')
    categories = cursor.fetchall()
    cursor.close()

    return render_template('report_issue.html', categories=categories)

@app.route('/view_issues')
def view_issues():
    try:
        cursor = mysql.connection.cursor()
        cursor.execute('''
            SELECT Problems.problem_id, Problems.description, Problems.location, Problems.status, 
                   Problems.reported_date, Categories.category_name
            FROM Problems
            JOIN Categories ON Problems.category_id = Categories.category_id
            ORDER BY Problems.problem_id DESC
        ''')
        issues = cursor.fetchall()
        cursor.close()

        return render_template('view_issues.html', issues=issues)

    except Exception as e:
        flash(f'Error fetching issues: {str(e)}', 'error')
        return redirect(url_for('index'))

@app.route('/issue/<int:issue_id>')
def issue_details(issue_id):
    cursor = mysql.connection.cursor()

    cursor.execute('''
        SELECT Problems.*, Categories.category_name, Users.name AS reported_by_name
        FROM Problems
        JOIN Categories ON Problems.category_id = Categories.category_id
        JOIN Users ON Problems.user_id = Users.user_id
        WHERE problem_id = %s
    ''', (issue_id,))
    issue = cursor.fetchone()

    cursor.execute('''
        SELECT Comments.*, Users.name AS commenter_name
        FROM Comments
        JOIN Users ON Comments.user_id = Users.user_id
        WHERE problem_id = %s
    ''', (issue_id,))
    comments = cursor.fetchall()

    cursor.close()

    return render_template('issue_details.html', issue=issue, comments=comments)

@app.route('/issue/<int:issue_id>/add_comment', methods=['POST'])
def add_comment(issue_id):
    if 'user' not in session or 'user_id' not in session['user']:
        flash('You must be logged in to add a comment.', 'error')
        return redirect(url_for('login'))

    user_id = session['user']['user_id']
    comment_text = request.form.get('comment_text')
    if not comment_text:
        flash('Comment text is required.', 'error')
        return redirect(url_for('issue_details', issue_id=issue_id))

    comment_date = datetime.datetime.now()

    try:
        cursor = mysql.connection.cursor()
        cursor.execute('INSERT INTO Comments (problem_id, user_id, comment_text, comment_date) VALUES (%s, %s, %s, %s)',
                       (issue_id, user_id, comment_text, comment_date))
        mysql.connection.commit()
        cursor.close()

    except Exception as e:
        flash(f'Error occurred while adding comment: {str(e)}', 'error')
    finally:
        return redirect(url_for('issue_details', issue_id=issue_id))

@app.route('/delete_comment/<int:comment_id>', methods=['POST'])
def delete_comment(comment_id):
    if 'user' not in session:
        flash('You must be logged in to delete a comment.', 'error')
        return redirect(url_for('login'))

    try:
        cursor = mysql.connection.cursor()

        cursor.execute('SELECT user_id, problem_id FROM Comments WHERE comment_id = %s', (comment_id,))
        comment = cursor.fetchone()

        if not comment:
            flash('Comment not found.', 'error')
            return redirect(url_for('view_issues'))

        if comment['user_id'] != session['user']['user_id']:
            flash('You are not authorized to delete this comment.', 'error')
            return redirect(url_for('issue_details', issue_id=comment['problem_id']))

        cursor.execute('DELETE FROM Comments WHERE comment_id = %s', (comment_id,))
        mysql.connection.commit()
        cursor.close()

        return redirect(url_for('issue_details', issue_id=comment['problem_id']))

    except Exception as e:
        flash(f'Failed to delete comment: {str(e)}', 'error')
        return redirect(url_for('issue_details', issue_id=comment['problem_id']))
@app.route('/update_status/<int:issue_id>', methods=['POST'])
def update_status(issue_id):
    if 'user' not in session or session['user']['role'] != 'authority':
        flash('You are not authorized to perform this action.', 'error')
        return redirect(url_for('view_issues'))

    if request.method == 'POST':
        status = request.form.get('status')  # Use .get() to avoid KeyError
        update_date = datetime.datetime.now()

        if not status:
            flash('Status is required.', 'error')
            return redirect(url_for('view_issues'))

        try:
            cursor = mysql.connection.cursor()

            # Update the Problems table
            cursor.execute('UPDATE Problems SET status = %s, resolved_date = %s WHERE problem_id = %s',
                           (status, update_date, issue_id))

            # Insert into statusupdates table
            cursor.execute('INSERT INTO statusupdates (problem_id, status, update_date) VALUES (%s, %s, %s)',
                           (issue_id, status, update_date))

            # Insert a notification for the user who reported the problem
            cursor.execute('''
                INSERT INTO Notifications (user_id, issue_id, message)
                SELECT user_id, %s, CONCAT('The status of your reported problem (ID: %s) has been updated to: ', %s)
                FROM Problems
                WHERE problem_id = %s
            ''', (issue_id, issue_id, status, issue_id))

            mysql.connection.commit()
            cursor.close()


            return redirect(url_for('view_issues'))

        except Exception as e:
            logging.error(f'Failed to update status: {str(e)}')  # Log the exception
            flash('Failed to update status.', 'error')
            mysql.connection.rollback()  # Rollback changes on error
            return redirect(url_for('view_issues'))


logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')

@app.route('/notifications')
def notifications():
    if 'user' not in session:
        flash('You must be logged in to view notifications.', 'error')
        return redirect(url_for('login'))

    user_id = session['user']['user_id']
    cursor = mysql.connection.cursor()

    cursor.execute('''
        SELECT * FROM Notifications
        WHERE user_id = %s
        ORDER BY created_at DESC
    ''', (user_id,))
    notifications = cursor.fetchall()

    logging.debug(f'Fetched notifications for user {user_id}: {notifications}')

    cursor.close()

    return render_template('notifications.html', notifications=notifications)

@app.route('/mark_as_read/<int:notification_id>', methods=['POST'])
def mark_as_read(notification_id):
    if 'user' not in session:
        flash('You must be logged in to mark notifications as read.', 'error')
        return redirect(url_for('login'))

    try:
        cursor = mysql.connection.cursor()
        cursor.execute('UPDATE Notifications SET status = %s WHERE notification_id = %s', ('read', notification_id))
        mysql.connection.commit()
        cursor.close()

        return redirect(url_for('notifications'))
    except Exception as e:
        flash(f'Failed to mark notification as read: {str(e)}', 'error')
        mysql.connection.rollback()  # Ensure rollback on error
        return redirect(url_for('notifications'))

@app.route('/mark_all_as_read', methods=['POST'])
def mark_all_as_read():
    if 'user' not in session:
        flash('You must be logged in to mark all notifications as read.', 'error')
        return redirect(url_for('login'))

    try:
        user_id = session['user']['user_id']
        cursor = mysql.connection.cursor()
        cursor.execute('UPDATE Notifications SET status = %s WHERE user_id = %s AND status = %s', ('read', user_id, 'unread'))
        mysql.connection.commit()
        cursor.close()

        return redirect(url_for('notifications'))
    except Exception as e:
        flash(f'Failed to mark all notifications as read: {str(e)}', 'error')
        mysql.connection.rollback()  # Ensure rollback on error
        return redirect(url_for('notifications'))

@app.route('/delete_notification/<int:notification_id>', methods=['POST'])
def delete_notification(notification_id):
    if 'user' not in session:
        flash('You must be logged in to delete notifications.', 'error')
        return redirect(url_for('login'))

    try:
        cursor = mysql.connection.cursor()
        cursor.execute('DELETE FROM Notifications WHERE notification_id = %s', (notification_id,))
        mysql.connection.commit()
        cursor.close()

        return redirect(url_for('notifications'))
    except Exception as e:
        flash(f'Failed to delete notification: {str(e)}', 'error')
        mysql.connection.rollback()  # Ensure rollback on error
        return redirect(url_for('notifications'))

@app.route('/delete_all_notifications', methods=['POST'])
def delete_all_notifications():
    if 'user' not in session:
        flash('You must be logged in to delete all notifications.', 'error')
        return redirect(url_for('login'))

    try:
        user_id = session['user']['user_id']
        cursor = mysql.connection.cursor()
        cursor.execute('DELETE FROM Notifications WHERE user_id = %s', (user_id,))
        mysql.connection.commit()
        cursor.close()

        return redirect(url_for('notifications'))
    except Exception as e:
        flash(f'Failed to delete all notifications: {str(e)}', 'error')
        mysql.connection.rollback()  # Ensure rollback on error
        return redirect(url_for('notifications'))

def get_unread_notifications_count():
    # Ensure session has user data
    if 'user' in session and 'user_id' in session['user']:
        user_id = session['user']['user_id']

        # Create a cursor object
        cursor = mysql.connection.cursor()

        try:
            # Execute the query to count unread notifications
            query = 'SELECT COUNT(*) FROM Notifications WHERE user_id = %s AND status = %s'
            cursor.execute(query, (user_id, 'unread'))

            # Fetch the result
            result = cursor.fetchone()

            # Log the result for debugging
            logging.debug(f"Query result for unread notifications count: {result}")

            # Extract count from result
            count = result[0] if result else 0
        except Exception as e:
            # Log the exception if any error occurs
            logging.error(f"Error fetching unread notifications count: {e}")
            count = 0
        finally:
            # Close the cursor
            cursor.close()

        return count

    # Return 0 if no user data is available in the session
    return 0


@app.context_processor
def inject_unread_notifications():
    return dict(unread_notifications=get_unread_notifications_count())

@app.route('/delete_issue/<int:issue_id>', methods=['POST'])
def delete_issue(issue_id):
    if 'user' not in session:
        flash('You need to be logged in to delete an issue.', 'error')
        return redirect(url_for('login'))

    user_id = session['user']['user_id']
    logging.debug(f"User ID from session: {user_id}")

    cursor = mysql.connection.cursor()
    cursor.execute('SELECT user_id FROM Problems WHERE problem_id = %s', (issue_id,))
    issue = cursor.fetchone()
    logging.debug(f"Issue fetched from database: {issue}")

    if issue is None:
        flash('Issue not found.', 'error')
        return redirect(url_for('view_issues'))

    if issue['user_id'] != user_id and session['user']['role'] != 'Admin':
        flash('You are not authorized to delete this issue.', 'error')
        return redirect(url_for('issue_details', issue_id=issue_id))

    try:
        cursor.execute('DELETE FROM StatusUpdates WHERE problem_id = %s', (issue_id,))
        cursor.execute('DELETE FROM Comments WHERE problem_id = %s', (issue_id,))
        cursor.execute('DELETE FROM Problems WHERE problem_id = %s', (issue_id,))
        mysql.connection.commit()

        logging.debug(f"Issue {issue_id} deleted successfully.")

    except IntegrityError as e:
        logging.error(f"Integrity error: {e}")
        flash('Failed to delete issue due to related records.', 'error')
    except Exception as e:
        logging.error(f"Error deleting issue: {e}")
        flash('Failed to delete issue.', 'error')
    finally:
        cursor.close()
        return redirect(url_for('view_issues'))

@app.route('/admin_dashboard')
@admin_required
def admin_dashboard():
    try:
        cursor = mysql.connection.cursor()
        cursor.execute('SELECT * FROM Users')
        users = cursor.fetchall()

        cursor.execute('''
            SELECT Problems.*, Categories.category_name, Users.name AS reported_by_name
            FROM Problems
            JOIN Categories ON Problems.category_id = Categories.category_id
            JOIN Users ON Problems.user_id = Users.user_id
            ORDER BY Problems.problem_id DESC
        ''')
        issues = cursor.fetchall()
        cursor.close()

        return render_template('admin_dashboard.html', users=users, issues=issues)

    except Exception as e:
        flash(f'Error fetching admin dashboard data: {str(e)}', 'error')
        return redirect(url_for('index'))

@app.route('/edit_user/<int:user_id>', methods=['GET', 'POST'])
@admin_required
def edit_user(user_id):
    cursor = mysql.connection.cursor()

    if request.method == 'POST':
        name = request.form['name']
        email = request.form['email']
        role = request.form['role']

        try:
            cursor.execute('''
                UPDATE Users
                SET name = %s, email = %s, role = %s
                WHERE user_id = %s
            ''', (name, email, role, user_id))
            mysql.connection.commit()
            flash('User updated successfully.', 'success')
        except IntegrityError:
            flash('Email address already in use.', 'error')
        except Exception as e:
            flash(f'Failed to update user: {str(e)}', 'error')
        finally:
            cursor.close()
            return redirect(url_for('admin_dashboard'))

    cursor.execute('SELECT * FROM Users WHERE user_id = %s', (user_id,))
    user = cursor.fetchone()
    cursor.close()

    if user is None:
        flash('User not found.', 'error')
        return redirect(url_for('admin_dashboard'))

    return render_template('edit_user.html', user=user)

@app.route('/admin_delete_user/<int:user_id>', methods=['POST'])
@admin_required
def admin_delete_user(user_id):
    cursor = mysql.connection.cursor()

    try:
        cursor.execute('DELETE FROM Users WHERE user_id = %s', (user_id,))
        mysql.connection.commit()

    except Exception as e:
        flash(f'Failed to delete user: {str(e)}', 'error')
    finally:
        cursor.close()
        return redirect(url_for('admin_dashboard'))

@app.route('/admin_update_issue_status/<int:issue_id>', methods=['POST'])
@admin_required
def admin_update_issue_status(issue_id):
    new_status = request.form['status']
    cursor = mysql.connection.cursor()

    try:
        cursor.execute('UPDATE Problems SET status = %s WHERE problem_id = %s', (new_status, issue_id))
        mysql.connection.commit()

    except Exception as e:
        flash(f'Failed to update issue status: {str(e)}', 'error')
    finally:
        cursor.close()
        return redirect(url_for('admin_dashboard'))





@app.route('/admin_delete_issue/<int:issue_id>', methods=['POST'])
@admin_required
def admin_delete_issue(issue_id):
    cursor = mysql.connection.cursor()

    try:
        cursor.execute('DELETE FROM StatusUpdates WHERE problem_id = %s', (issue_id,))
        cursor.execute('DELETE FROM Comments WHERE problem_id = %s', (issue_id,))
        cursor.execute('DELETE FROM Problems WHERE problem_id = %s', (issue_id,))
        mysql.connection.commit()

    except Exception as e:
        flash(f'Failed to delete issue: {str(e)}', 'error')
    finally:
        cursor.close()
        return redirect(url_for('admin_dashboard'))

if __name__ == '__main__':
    app.run(debug=True)